$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceDir = Join-Path $root 'Bible-niv-main'
$booksPath = Join-Path $sourceDir 'Books.json'
$jsonOut = Join-Path $root 'data\verses.json'
$jsOut = Join-Path $root 'data\verses.js'

$books = Get-Content -Raw -Encoding UTF8 $booksPath | ConvertFrom-Json
$bundle = [ordered]@{}

foreach ($bookName in $books) {
  $bookPath = Join-Path $sourceDir ($bookName + '.json')
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
[System.IO.File]::WriteAllText($jsonOut, $json + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($jsOut, "window.BIBLE_DATA = $json;" + [Environment]::NewLine, [System.Text.Encoding]::UTF8)

Write-Output "Wrote $($books.Count) books to $jsonOut"
Write-Output "Wrote browser bundle to $jsOut"
