param(
  [string]$SourceJson = 'Seputagint\septuagint-json\septuagint.json',
  [string]$OutputDir = 'Bible-lxx-main'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedSourceJson = Join-Path $root $SourceJson
$resolvedOutputDir = Join-Path $root $OutputDir

$bookNameMap = [ordered]@{
  '01-gen-nets' = 'Genesis'
  '02-exod-nets' = 'Exodus'
  '03-leu-nets' = 'Leviticus'
  '04-num-nets' = 'Numbers'
  '05-deut-nets' = 'Deuteronomy'
  '06-iesous-nets' = 'Joshua'
  '07-judges-nets' = 'Judges'
  '08-routh-nets' = 'Ruth'
  '09-1reigns-nets' = '1 Samuel'
  '10-2reigns-nets' = '2 Samuel'
  '11-3reigns-nets' = '1 Kings'
  '12-4reigns-nets' = '2 Kings'
  '13-1suppl-nets' = '1 Chronicles'
  '14-2suppl-nets' = '2 Chronicles'
  '15-1esdras-nets' = '1 Esdras'
  '16-2esdras-nets' = '2 Esdras'
  '17-esther-nets' = 'Esther'
  '18-ioudith-nets' = 'Judith'
  '19-tobit-nets' = 'Tobit'
  '20-1makk-nets' = '1 Maccabees'
  '21-2makk-nets' = '2 Maccabees'
  '22-3makk-nets' = '3 Maccabees'
  '23-4makk-nets' = '4 Maccabees'
  '24-ps-nets' = 'Psalms'
  '25-proverbs-nets' = 'Proverbs'
  '26-eccles-nets' = 'Ecclesiastes'
  '27-song-nets' = 'Song of Solomon'
  '28-iob-nets' = 'Job'
  '29-wissal-nets' = 'Wisdom of Solomon'
  '30-sirach-nets' = 'Sirach'
  '31-pssal-nets' = 'Psalms of Solomon'
  '32-twelve-nets' = 'Twelve Prophets'
  '33-esaias-nets' = 'Isaiah'
  '34-ieremias-nets' = 'Jeremiah'
  '35-barouch-nets' = 'Baruch'
  '36-lam-nets' = 'Lamentations'
  '37-letier-nets' = 'Letter of Jeremiah'
  '38-iezekiel-nets' = 'Ezekiel'
  '39-sousanna-nets' = 'Susanna'
  '40-daniel-nets' = 'Daniel'
  '41-bel-nets' = 'Bel and the Dragon'
}

function Normalize-Text {
  param([string]$Text)

  if ($null -eq $Text) {
    return ''
  }

  $normalized = $Text
  $normalized = $normalized -replace '\s+', ' '

  return $normalized.Trim()
}

if (-not (Test-Path $resolvedSourceJson)) {
  throw "Missing Septuagint source JSON: $resolvedSourceJson"
}

$raw = Get-Content -Raw -Encoding UTF8 $resolvedSourceJson | ConvertFrom-Json
if (-not $raw.books) {
  throw "Unexpected Septuagint JSON format in $resolvedSourceJson"
}

New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

$books = New-Object System.Collections.Generic.List[string]

foreach ($book in $raw.books) {
  $bookId = [string]$book.bookId
  if (-not $bookNameMap.Contains($bookId)) {
    throw "No output book mapping configured for $bookId"
  }

  $bookName = $bookNameMap[$bookId]
  $books.Add($bookName)

  $chapters = foreach ($chapter in $book.chapters) {
    $verses = foreach ($verse in ($chapter.verses | Sort-Object { [int]$_.verse })) {
      [ordered]@{
        verse = [string]$verse.verse
        text  = Normalize-Text $verse.text
      }
    }

    [ordered]@{
      chapter = [string]$chapter.chapter
      verses  = @($verses)
    }
  }

  $bookPayload = [ordered]@{
    book     = $bookName
    chapters = @($chapters)
  }

  $bookPath = Join-Path $resolvedOutputDir ($bookName + '.json')
  [System.IO.File]::WriteAllText(
    $bookPath,
    (($bookPayload | ConvertTo-Json -Depth 100 -Compress:$false) + [Environment]::NewLine),
    [System.Text.Encoding]::UTF8
  )
}

$booksPath = Join-Path $resolvedOutputDir 'Books.json'
[System.IO.File]::WriteAllText(
  $booksPath,
  ((@($books) | ConvertTo-Json -Depth 5 -Compress:$false) + [Environment]::NewLine),
  [System.Text.Encoding]::UTF8
)

Write-Output "Wrote $($books.Count) Septuagint books to $resolvedOutputDir"
