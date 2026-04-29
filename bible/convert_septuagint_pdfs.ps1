param(
  [string]$SourceDir = 'Seputagint',
  [string]$StructureJson = 'Seputagint\septuagint-json\septuagint.json',
  [string]$OutputDir = 'Bible-lxx-pdf-main',
  [switch]$GenesisOnly
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedSourceDir = Join-Path $root $SourceDir
$resolvedStructureJson = Join-Path $root $StructureJson
$resolvedOutputDir = Join-Path $root $OutputDir
$script:Warnings = New-Object System.Collections.Generic.List[string]

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

function Get-PdfToTextPath {
  $exe = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter 'pdftotext.exe' -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName
  if (-not $exe) {
    throw 'pdftotext.exe was not found. Install Poppler first.'
  }
  return $exe
}

function Join-WordLine {
  param([object[]]$Words)

  $text = ''
  foreach ($word in ($Words | Sort-Object x)) {
    if ([string]::IsNullOrWhiteSpace($word.t)) {
      continue
    }

    if ($text.Length -eq 0) {
      $text = $word.t
    } elseif ($word.t -match '^[,.;:?!\)\]]$') {
      $text += $word.t
    } elseif ($text -match '[\(\[]$') {
      $text += $word.t
    } else {
      $text += ' ' + $word.t
    }
  }

  return $text.Trim()
}

function Get-BookTextFromPdf {
  param(
    [string]$PdfPath,
    [string]$PdfToTextExe
  )

  $tempHtml = Join-Path $env:TEMP ([IO.Path]::GetFileNameWithoutExtension($PdfPath) + '-bbox-layout.html')
  & $PdfToTextExe -enc UTF-8 -bbox-layout $PdfPath $tempHtml

  [xml]$doc = Get-Content -Raw -Encoding UTF8 $tempHtml
  $pages = @($doc.html.body.doc.page)
  $orderedLines = New-Object System.Collections.Generic.List[string]

  foreach ($page in $pages) {
    $width = [double]$page.width
    $height = [double]$page.height
    $midpoint = $width / 2.0
    $splitPoint = $midpoint - 10

    $leftLines = New-Object System.Collections.Generic.List[object]
    $rightLines = New-Object System.Collections.Generic.List[object]

    foreach ($line in $page.SelectNodes('.//*[local-name()="line"]')) {
      $yMin = [double]$line.yMin
      $xMin = [double]$line.xMin
      $xMax = [double]$line.xMax

      if ($yMin -lt 72 -or $yMin -gt ($height - 36)) {
        continue
      }

      $words = New-Object System.Collections.Generic.List[object]
      foreach ($word in $line.SelectNodes('./*[local-name()="word"]')) {
        $text = ([string]$word.InnerText).Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
          continue
        }

        $words.Add([pscustomobject]@{
          x = [double]$word.xMin
          t = $text
        })
      }

      if ($words.Count -eq 0) {
        continue
      }

      $leftWords = @($words | Where-Object { $_.x -lt $splitPoint })
      $rightWords = @($words | Where-Object { $_.x -ge $splitPoint })

      if ($leftWords.Count -gt 0) {
        $leftText = Join-WordLine $leftWords
        if (
          -not [string]::IsNullOrWhiteSpace($leftText) -and
          $leftText -notmatch '^\d+$' -and
          $leftText -notmatch '^[IVXLCDM]+$' -and
          $leftText -notmatch 'qxd' -and
          $leftText -notmatch '^Page ' -and
          $leftText -notmatch '^TO THE READER$'
        ) {
          $leftLines.Add([pscustomobject]@{
            y = [math]::Round($yMin, 1)
            x = [math]::Round(([double]$leftWords[0].x), 1)
            text = $leftText
          })
        }
      }

      if ($rightWords.Count -gt 0) {
        $rightText = Join-WordLine $rightWords
        if (
          -not [string]::IsNullOrWhiteSpace($rightText) -and
          $rightText -notmatch '^\d+$' -and
          $rightText -notmatch '^[IVXLCDM]+$' -and
          $rightText -notmatch 'qxd' -and
          $rightText -notmatch '^Page ' -and
          $rightText -notmatch '^TO THE READER$'
        ) {
          $rightLines.Add([pscustomobject]@{
            y = [math]::Round($yMin, 1)
            x = [math]::Round(([double]$rightWords[0].x), 1)
            text = $rightText
          })
        }
      }
    }

    foreach ($entry in ($leftLines | Sort-Object y, x)) {
      $orderedLines.Add($entry.text)
    }
    foreach ($entry in ($rightLines | Sort-Object y, x)) {
      $orderedLines.Add($entry.text)
    }
  }

  $text = ($orderedLines -join "`n")
  $text = $text -replace '([A-Za-z])-\s*\n\s*([A-Za-z])', '$1$2'
  $text = $text -replace '\s+', ' '
  return $text.Trim()
}

function Clean-VerseText {
  param([string]$Text)

  $value = $Text -replace "`r`n", ' '
  $value = $value -replace "`n", ' '
  $value = $value -replace '([A-Za-z])-\s+([A-Za-z])', '$1$2'
  $value = $value -replace '\s+', ' '
  $value = $value -replace '\s+([,.;:?!])', '$1'
  return $value.Trim()
}

function Get-AnchorPattern {
  param(
    [string]$Text,
    [int]$MaxWords = 7
  )

  $words = [regex]::Matches($Text, "[A-Za-z']+") | Select-Object -ExpandProperty Value
  if (-not $words -or $words.Count -eq 0) {
    throw "Could not build anchor pattern from: $Text"
  }

  $wordCount = [Math]::Min($MaxWords, $words.Count)
  $escaped = @()
  for ($i = 0; $i -lt $wordCount; $i++) {
    $anchorWord = $words[$i]
    if ($anchorWord.Length -gt 4) {
      $anchorWord = $anchorWord.Substring(0, 4)
    }

    $letters = [regex]::Matches($anchorWord, ".") | Select-Object -ExpandProperty Value
    $pieces = @()
    foreach ($letter in $letters) {
      $pieces += ([regex]::Escape($letter) + '\s*')
    }
    $escaped += ((($pieces -join '') -replace '\\s\*$', '') + '\w*')
  }
  return ($escaped -join '\W+')
}

function Get-ExactAnchorPattern {
  param(
    [string]$Text,
    [int]$MaxWords = 7
  )

  $words = [regex]::Matches($Text, "[A-Za-z']+") | Select-Object -ExpandProperty Value
  if (-not $words -or $words.Count -eq 0) {
    throw "Could not build exact anchor pattern from: $Text"
  }

  $wordCount = [Math]::Min($MaxWords, $words.Count)
  $escaped = @()
  for ($i = 0; $i -lt $wordCount; $i++) {
    $escaped += [regex]::Escape($words[$i])
  }

  return ($escaped -join '\W+')
}

function Get-ChapterBounds {
  param(
    [string]$BookText,
    [object[]]$ChapterList,
    [int]$ChapterIndex,
    [int]$Cursor,
    [string]$BookName
  )

  $chapterNumber = [int]$ChapterList[$ChapterIndex].chapter
  $chapterAnchorText = $null
  foreach ($verseEntry in @($ChapterList[$ChapterIndex].verses)) {
    if ([regex]::IsMatch([string]$verseEntry.text, "[A-Za-z']")) {
      $chapterAnchorText = [string]$verseEntry.text
      break
    }
  }
  if (-not $chapterAnchorText) {
    $script:Warnings.Add("$BookName chapter $chapterNumber missing: no usable chapter anchor text.")
    return $null
  }

  $chapterStart = $null
  foreach ($builder in @(
    { param($text) Get-ExactAnchorPattern -Text $text -MaxWords 7 },
    { param($text) Get-ExactAnchorPattern -Text $text -MaxWords 5 },
    { param($text) Get-AnchorPattern -Text $text -MaxWords 7 },
    { param($text) Get-AnchorPattern -Text $text -MaxWords 5 }
  )) {
    try {
      $anchorPattern = & $builder $chapterAnchorText
    } catch {
      continue
    }
    $chapterSearchText = $BookText.Substring($Cursor)
    $chapterMatch = [regex]::Match($chapterSearchText, $anchorPattern, 'IgnoreCase')
    if ($chapterMatch.Success) {
      $chapterStart = $Cursor + $chapterMatch.Index
      break
    }
  }

  if ($null -eq $chapterStart) {
    $script:Warnings.Add("$BookName chapter $chapterNumber missing: could not find chapter start.")
    return $null
  }

  $chapterEnd = $BookText.Length
  if ($ChapterIndex -lt $ChapterList.Count - 1) {
    $nextAnchorText = $null
    foreach ($verseEntry in @($ChapterList[$ChapterIndex + 1].verses)) {
      if ([regex]::IsMatch([string]$verseEntry.text, "[A-Za-z']")) {
        $nextAnchorText = [string]$verseEntry.text
        break
      }
    }
    if (-not $nextAnchorText) {
      $script:Warnings.Add("$BookName chapter $($ChapterNumber + 1) missing: no usable next chapter anchor text.")
      $nextStart = $BookText.Length
      return [pscustomobject]@{
        Start = $chapterStart
        End = $nextStart
      }
    }

    $nextStart = $null
    foreach ($builder in @(
      { param($text) Get-ExactAnchorPattern -Text $text -MaxWords 7 },
      { param($text) Get-ExactAnchorPattern -Text $text -MaxWords 5 },
      { param($text) Get-AnchorPattern -Text $text -MaxWords 7 },
      { param($text) Get-AnchorPattern -Text $text -MaxWords 5 }
    )) {
      try {
        $nextAnchorPattern = & $builder $nextAnchorText
      } catch {
        continue
      }
      $nextSearchText = $BookText.Substring($chapterStart + 1)
      $nextMatch = [regex]::Match($nextSearchText, $nextAnchorPattern, 'IgnoreCase')
      if ($nextMatch.Success) {
        $nextStart = $chapterStart + 1 + $nextMatch.Index
        break
      }
    }

    if ($null -eq $nextStart) {
      $script:Warnings.Add("$BookName chapter $chapterNumber warning: could not find next chapter start; using end of book.")
      $nextStart = $BookText.Length
    }
    $chapterEnd = $nextStart
  }

  return [pscustomobject]@{
    Start = $chapterStart
    End = $chapterEnd
  }
}

function Split-ChapterVerses {
  param(
    [string]$ChapterText,
    [object[]]$VerseList,
    [string]$BookName,
    [int]$ChapterNumber
  )

  $verseMap = @{}
  foreach ($verseEntry in $VerseList) {
    $verseMap[[int]$verseEntry.verse] = [string]$verseEntry.text
  }
  $maxVerse = (($VerseList | Measure-Object -Property verse -Maximum).Maximum -as [int])

  $starts = @{}
  $starts[1] = 0
  $searchStart = 1

  for ($verseNum = 2; $verseNum -le $maxVerse; $verseNum++) {
    if ($searchStart -ge $ChapterText.Length) {
      $script:Warnings.Add("$BookName $ChapterNumber verse $verseNum missing: chapter text exhausted.")
      continue
    }

    $remaining = $ChapterText.Substring($searchStart)
    $marker = $null
    if ($verseMap.ContainsKey($verseNum)) {
      foreach ($wordLimit in @(7, 5)) {
        try {
          $anchorPattern = Get-AnchorPattern -Text $verseMap[$verseNum] -MaxWords $wordLimit
        } catch {
          continue
        }
        $marker = [regex]::Match($remaining, $anchorPattern, 'IgnoreCase')
        if ($marker.Success) {
          break
        }
      }
    }

    if (-not $marker.Success) {
      $marker = [regex]::Match($remaining, "(?<!\d)\b$verseNum\b(?=\s)")
    }

    if (-not $marker.Success) {
      $script:Warnings.Add("$BookName $ChapterNumber verse $verseNum missing: no anchor found.")
      continue
    }

    $starts[$verseNum] = $searchStart + $marker.Index
    $searchStart = $starts[$verseNum] + 1
  }

  $versesOut = @()
  for ($verseNumber = 1; $verseNumber -le $maxVerse; $verseNumber++) {
    if (-not $starts.ContainsKey($verseNumber)) {
      $versesOut += [ordered]@{
        verse = [string]$verseNumber
        text = ''
      }
      continue
    }

    $start = $starts[$verseNumber]
    $nextStart = $null
    for ($candidate = $verseNumber + 1; $candidate -le $maxVerse; $candidate++) {
      if ($starts.ContainsKey($candidate)) {
        $nextStart = $starts[$candidate]
        break
      }
    }
    $end = if ($null -ne $nextStart) { $nextStart } else { $ChapterText.Length }

    $versesOut += [ordered]@{
      verse = [string]$verseNumber
      text = Clean-VerseText ($ChapterText.Substring($start, $end - $start))
    }
  }

  return @($versesOut)
}

if (-not (Test-Path $resolvedStructureJson)) {
  throw "Missing structure JSON: $resolvedStructureJson"
}

New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

$pdftotext = Get-PdfToTextPath
$structure = Get-Content -Raw -Encoding UTF8 $resolvedStructureJson | ConvertFrom-Json
$booksToWrite = New-Object System.Collections.Generic.List[string]
$books = @($structure.books)
if ($GenesisOnly) {
  $books = @($books | Where-Object { $_.bookId -eq '01-gen-nets' })
}

foreach ($book in $books) {
  $bookId = [string]$book.bookId
  if (-not $bookNameMap.Contains($bookId)) {
    throw "No output mapping for $bookId"
  }

  $bookName = $bookNameMap[$bookId]
  $pdfPath = Join-Path $resolvedSourceDir ($bookId + '.pdf')
  if (-not (Test-Path $pdfPath)) {
    throw "Missing PDF for $bookId at $pdfPath"
  }

  $bookText = Get-BookTextFromPdf -PdfPath $pdfPath -PdfToTextExe $pdftotext
  $chaptersOut = @()
  $cursor = 0
  $chapterList = @($book.chapters)

  for ($chapterIndex = 0; $chapterIndex -lt $chapterList.Count; $chapterIndex++) {
    $chapter = $chapterList[$chapterIndex]
    $chapterNumber = [int]$chapter.chapter
    $bounds = Get-ChapterBounds -BookText $bookText -ChapterList $chapterList -ChapterIndex $chapterIndex -Cursor $cursor -BookName $bookName
    if ($null -eq $bounds) {
      $versesOut = @()
      $maxVerse = ((@($chapter.verses) | Measure-Object -Property verse -Maximum).Maximum -as [int])
      for ($v = 1; $v -le $maxVerse; $v++) {
        $versesOut += [ordered]@{
          verse = [string]$v
          text = ''
        }
      }
    } else {
      $chapterChunk = $bookText.Substring($bounds.Start, $bounds.End - $bounds.Start).Trim()
      $versesOut = Split-ChapterVerses -ChapterText $chapterChunk -VerseList @($chapter.verses) -BookName $bookName -ChapterNumber $chapterNumber
      $cursor = $bounds.End
    }

    $chaptersOut += [ordered]@{
      chapter = [string]$chapterNumber
      verses = @($versesOut)
    }
  }

  $bookPayload = [ordered]@{
    book = $bookName
    chapters = @($chaptersOut)
  }

  $bookPath = Join-Path $resolvedOutputDir ($bookName + '.json')
  [System.IO.File]::WriteAllText(
    $bookPath,
    (($bookPayload | ConvertTo-Json -Depth 100 -Compress:$false) + [Environment]::NewLine),
    [System.Text.Encoding]::UTF8
  )
  $booksToWrite.Add($bookName)
}

[System.IO.File]::WriteAllText(
  (Join-Path $resolvedOutputDir 'Books.json'),
  ((@($booksToWrite) | ConvertTo-Json -Depth 5 -Compress:$false) + [Environment]::NewLine),
  [System.Text.Encoding]::UTF8
)

if ($script:Warnings.Count -gt 0) {
  [System.IO.File]::WriteAllText(
    (Join-Path $resolvedOutputDir 'conversion-warnings.txt'),
    (($script:Warnings -join [Environment]::NewLine) + [Environment]::NewLine),
    [System.Text.Encoding]::UTF8
  )
}

Write-Output "Wrote $($booksToWrite.Count) books from Septuagint PDFs to $resolvedOutputDir"
