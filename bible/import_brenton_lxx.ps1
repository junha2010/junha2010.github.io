param(
  [string]$SourceDir = 'brenton-source\eng-Brenton_usfm',
  [string]$OutputDir = 'Bible-lxx-pdf-main'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedSourceDir = Join-Path $root $SourceDir
$resolvedOutputDir = Join-Path $root $OutputDir

if (-not (Test-Path $resolvedSourceDir)) {
  throw "Source directory not found: $resolvedSourceDir"
}

New-Item -ItemType Directory -Path $resolvedOutputDir -Force | Out-Null
Get-ChildItem -Path $resolvedOutputDir -Filter *.json | ForEach-Object {
  Remove-Item -LiteralPath $_.FullName -Force
}

$bookFiles = [ordered]@{
  '02-GENeng-Brenton.usfm' = 'Genesis'
  '03-EXOeng-Brenton.usfm' = 'Exodus'
  '04-LEVeng-Brenton.usfm' = 'Leviticus'
  '05-NUMeng-Brenton.usfm' = 'Numbers'
  '06-DEUeng-Brenton.usfm' = 'Deuteronomy'
  '07-JOSeng-Brenton.usfm' = 'Joshua'
  '08-JDGeng-Brenton.usfm' = 'Judges'
  '09-RUTeng-Brenton.usfm' = 'Ruth'
  '10-1SAeng-Brenton.usfm' = 'Kings I'
  '11-2SAeng-Brenton.usfm' = 'Kings II'
  '12-1KIeng-Brenton.usfm' = 'Kings III'
  '13-2KIeng-Brenton.usfm' = 'Kings IV'
  '14-1CHeng-Brenton.usfm' = 'Chronicles I'
  '15-2CHeng-Brenton.usfm' = 'Chronicles II'
  '54-1ESeng-Brenton.usfm' = 'Esdras I'
  '16-EZReng-Brenton.usfm' = 'Ezra and Nehemiah'
  '43-ESGeng-Brenton.usfm' = 'Esther (Greek)'
  '41-TOBeng-Brenton.usfm' = 'Tobit'
  '42-JDTeng-Brenton.usfm' = 'Judith'
  '52-1MAeng-Brenton.usfm' = 'Maccabees I'
  '53-2MAeng-Brenton.usfm' = 'Maccabees II'
  '57-3MAeng-Brenton.usfm' = 'Maccabees III'
  '59-4MAeng-Brenton.usfm' = 'Maccabees IV'
  '20-PSAeng-Brenton.usfm' = 'Psalms'
  '21-PROeng-Brenton.usfm' = 'Proverbs'
  '22-ECCeng-Brenton.usfm' = 'Ecclesiastes'
  '23-SNGeng-Brenton.usfm' = 'Song of Solomon'
  '19-JOBeng-Brenton.usfm' = 'Job'
  '45-WISeng-Brenton.usfm' = 'Wisdom of Solomon'
  '46-SIReng-Brenton.usfm' = 'Wisdom Of Jesus The Son Of Sirach (Ecclesiasticus)'
  '55-MANeng-Brenton.usfm' = 'The Prayer of Manasses'
  '29-HOSeng-Brenton.usfm' = 'Osee'
  '30-JOLeng-Brenton.usfm' = 'Joel'
  '31-AMOeng-Brenton.usfm' = 'Amos'
  '32-OBAeng-Brenton.usfm' = 'Obdias'
  '33-JONeng-Brenton.usfm' = 'Jonas'
  '34-MICeng-Brenton.usfm' = 'Michæas'
  '35-NAMeng-Brenton.usfm' = 'Naum'
  '36-HABeng-Brenton.usfm' = 'Ambacum'
  '37-ZEPeng-Brenton.usfm' = 'Sophonias'
  '38-HAGeng-Brenton.usfm' = 'Aggæus'
  '39-ZECeng-Brenton.usfm' = 'Zacharias'
  '40-MALeng-Brenton.usfm' = 'Malachias'
  '24-ISAeng-Brenton.usfm' = 'Esaias'
  '25-JEReng-Brenton.usfm' = 'Jeremias'
  '47-BAReng-Brenton.usfm' = 'Baruch'
  '26-LAMeng-Brenton.usfm' = 'Lamentations'
  '48-LJEeng-Brenton.usfm' = 'Epistle of Jeremy'
  '27-EZKeng-Brenton.usfm' = 'Jezekiel'
  '50-SUSeng-Brenton.usfm' = 'Susanna'
  '66-DAGeng-Brenton.usfm' = 'Daniel (Greek)'
  '51-BELeng-Brenton.usfm' = 'Bel and the Dragon'
}

function Clean-UsfmText {
  param([string]$Text)

  $value = [string]$Text
  if (-not $value) {
    return ''
  }

  $value = $value -replace '\\f\s+.*?\\f\*', ' '
  $value = $value -replace '\\x\s+.*?\\x\*', ' '
  $value = $value -replace '\\add\s+(.+?)\\add\*', '$1'
  $value = $value -replace '\\sc\s+(.+?)\\sc\*', '$1'
  $value = $value -replace '\\nd\s+(.+?)\\nd\*', '$1'
  $value = $value -replace '\\wj\s+(.+?)\\wj\*', '$1'
  $value = $value -replace '\\qac\s+(.+?)\\qac\*', '$1'
  $value = $value -replace '\\it\s+(.+?)\\it\*', '$1'
  $value = $value -replace '\\bd\s+(.+?)\\bd\*', '$1'
  $value = $value -replace '\\[A-Za-z0-9]+\*?', ' '
  $value = $value -replace '\s+', ' '
  $value = $value -replace '\s+([,.;:?!])', '$1'
  return $value.Trim()
}

function Convert-UsfmBook {
  param(
    [string]$Path,
    [string]$BookName
  )

  $lines = Get-Content -Encoding UTF8 -Path $Path
  $chapters = @()
  $currentChapterNumber = $null
  $currentChapterVerses = @()
  $currentVerseNumber = $null
  $currentVerseText = ''

  foreach ($rawLine in $lines) {
    $line = $rawLine.Trim()
    if (-not $line) {
      continue
    }

    if ($line -match '^\\c\s+(\d+)') {
      if ($null -ne $currentVerseNumber) {
        $text = Clean-UsfmText $currentVerseText
        if ($text) {
          $currentChapterVerses += [pscustomobject]@{
            verse = [string]$currentVerseNumber
            text = $text
          }
        }
        $currentVerseNumber = $null
        $currentVerseText = ''
      }

      if ($null -ne $currentChapterNumber) {
        $chapters += [pscustomobject]@{
          chapter = [string]$currentChapterNumber
          verses = @($currentChapterVerses)
        }
      }

      $currentChapterNumber = [int]$matches[1]
      $currentChapterVerses = @()
      continue
    }

    if ($line -match '^\\v\s+(\d+[A-Za-z]?)\s*(.*)$') {
      if ($null -ne $currentVerseNumber) {
        $text = Clean-UsfmText $currentVerseText
        if ($text) {
          $currentChapterVerses += [pscustomobject]@{
            verse = [string]$currentVerseNumber
            text = $text
          }
        }
      }

      $currentVerseNumber = $matches[1]
      $currentVerseText = $matches[2]
      continue
    }

    if ($null -ne $currentVerseNumber) {
      $continuation = $line -replace '^\\[A-Za-z0-9*]+\s*', ''
      if ($continuation) {
        $currentVerseText = ($currentVerseText + ' ' + $continuation).Trim()
      }
    }
  }

  if ($null -ne $currentVerseNumber) {
    $text = Clean-UsfmText $currentVerseText
    if ($text) {
      $currentChapterVerses += [pscustomobject]@{
        verse = [string]$currentVerseNumber
        text = $text
      }
    }
  }

  if ($null -ne $currentChapterNumber) {
    $chapters += [pscustomobject]@{
      chapter = [string]$currentChapterNumber
      verses = @($currentChapterVerses)
    }
  }

  return [pscustomobject]@{
    book = $BookName
    chapters = @($chapters)
  }
}

$bookOrder = New-Object System.Collections.Generic.List[string]

foreach ($entry in $bookFiles.GetEnumerator()) {
  $sourcePath = Join-Path $resolvedSourceDir $entry.Key
  if (-not (Test-Path $sourcePath)) {
    throw "Missing source file: $sourcePath"
  }

  $bookName = $entry.Value
  $bookData = Convert-UsfmBook -Path $sourcePath -BookName $bookName
  $bookJson = $bookData | ConvertTo-Json -Depth 100
  $outputPath = Join-Path $resolvedOutputDir ($bookName + '.json')
  [System.IO.File]::WriteAllText($outputPath, $bookJson + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
  $bookOrder.Add($bookName)
}

$booksJson = @($bookOrder) | ConvertTo-Json
[System.IO.File]::WriteAllText((Join-Path $resolvedOutputDir 'Books.json'), $booksJson + [Environment]::NewLine, [System.Text.Encoding]::UTF8)

Write-Output "Imported $($bookOrder.Count) Brenton LXX books into $resolvedOutputDir"
