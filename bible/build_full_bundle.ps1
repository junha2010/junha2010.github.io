param(
  [string]$SourceDir = 'Bible-niv-main',
  [string]$JsonOut = 'data\verses.json',
  [string]$JsOut = 'data\verses.js',
  [string]$BundleKey = 'niv',
  [string]$LegacyGlobalName = 'BIBLE_DATA'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedSourceDir = Join-Path $root $SourceDir
$resolvedJsonOut = Join-Path $root $JsonOut
$resolvedJsOut = Join-Path $root $JsOut
$booksPath = Join-Path $resolvedSourceDir 'Books.json'

$books = Get-Content -Raw -Encoding UTF8 $booksPath | ConvertFrom-Json
$bundle = [ordered]@{}

foreach ($bookName in $books) {
  $bookPath = Join-Path $resolvedSourceDir ($bookName + '.json')
  if (-not (Test-Path $bookPath)) {
    throw "Missing source file for $bookName"
  }

  $rawBook = Get-Content -Raw -Encoding UTF8 $bookPath | ConvertFrom-Json
  $chapters = [ordered]@{}

  foreach ($chapter in $rawBook.chapters) {
    $chapterNumber = [string]$chapter.chapter
    $sortedVerses = @($chapter.verses | Sort-Object { [int]$_.verse } | ForEach-Object { $_.text })
    $chapters[$chapterNumber] = $sortedVerses
  }

  $bundle[$bookName] = $chapters
}

$json = $bundle | ConvertTo-Json -Depth 100
$jsLines = @(
  'window.BIBLE_DATA_BUNDLES = window.BIBLE_DATA_BUNDLES || {};'
  "window.BIBLE_DATA_BUNDLES['$BundleKey'] = $json;"
)

if ($LegacyGlobalName) {
  $jsLines += "window.$LegacyGlobalName = window.BIBLE_DATA_BUNDLES['$BundleKey'];"
}

[System.IO.File]::WriteAllText($resolvedJsonOut, $json + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($resolvedJsOut, ($jsLines -join [Environment]::NewLine) + [Environment]::NewLine, [System.Text.Encoding]::UTF8)

Write-Output "Wrote $($books.Count) books from $resolvedSourceDir to $resolvedJsonOut"
Write-Output "Wrote browser bundle to $resolvedJsOut"
