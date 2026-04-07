param(
  [string]$SourceDir = 'Bible-lxx-pdf-main',
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedSourceDir = Join-Path $root $SourceDir

if (-not (Test-Path $resolvedSourceDir)) {
  throw "Source directory not found: $resolvedSourceDir"
}

$editorialStartPattern = [regex]'(?i)(\blexica and grammars\b|\bBIBLIOGRAPHICAL NOTE\b|\bTO THE READE\b|\bAlbert Pietersma\b|\bOakTree Software\b|\bScholars Press\b|\bThe Cambridge Bible Commentary\b|\btranslation process\b|\bNETS\b|\bNRSV\b|\bSeptuagintal\b|\bMelbourne Symposium\b|\bGreek Text of\b|\binterlinear text\b|\btranslation committee\b|\bYale University Press\b|\bOxford University Press\b|\bwww\.oup\.com\b|\bMadison Avenue\b|\bAll rights reserved\b|\bcopyright\b|\bPublished by Oxford\b|\bprinted in the\b|\bregistered trademark\b|\bobjective of excellence\b|\bBlue Heron Bookcraft\b|\bTHEODOTION\b|\bOLD GREEK\b)'
$editorialResumePattern = [regex]'(?i)(\bbeing in the firmament\b|\bThere was a man\b|\bAnd it came about\b|\bAnd it happened\b|\bfor Iob said\b|\bProverbs of Salomon\b|\bJudges B\b|\bEsdrelom\b|\buntil one comes\b|\bAnd the woman went on her way\b|\bthe sons of Israel were inquiring\b|\bwho reigned in Israel\b|\bAnd an angel of the Lord said\b|\bAnd Hambakoum shouted\b|\bNow on the seventh day\b|\bAnd Daniel said\b|\bAnd he pulled him out\b)'
$junkVersePattern = [regex]'(?i)(Oxford University Press|www\.oup\.com|All rights reserved|registered trademark|Madison Avenue|A New English Translation of the Septuagint|International Organization for Septuagint|without written permission|Blue Heron Bookcraft|copyright page|quotations marked|Printed in the|Published by Oxford|objective of excellence|tradeand)'
$footnoteRunPattern = [regex]"(?i)\s+[a-z](?:\s*(?:I\.e\.|Or|Possibly|Lacking in Gk|one mina|Antecedent unclear|Heb\s*=|Or by|Or in threes|I\.e\.\s+Daniel's|I\.e\.\s+Bel|and her daughters =))[^A-Z""]*(?=(?:\s+[A-Z""]|\s*$))"
$middleVerseNumberPattern = [regex]'(?<=\S)\s+\d{1,3}(?=\s+[A-Z"])'

function Remove-EditorialSegment {
  param([string]$Text)

  $cleaned = if ($null -eq $Text) { '' } else { [string]$Text }
  $cleaned = $cleaned.Trim()
  if (-not $cleaned) {
    return ''
  }

  $guard = 0
  while ($guard -lt 8) {
    $guard += 1
    $startMatch = $editorialStartPattern.Match($cleaned)
    if (-not $startMatch.Success) {
      break
    }

    $startIndex = $startMatch.Index
    $resumeSearchStart = [Math]::Min($cleaned.Length, $startIndex + $startMatch.Length + 40)
    $tail = $cleaned.Substring($resumeSearchStart)
    $resumeMatch = $editorialResumePattern.Match($tail)

    if ($resumeMatch.Success) {
      $prefix = $cleaned.Substring(0, $startIndex).Trim()
      $suffix = $tail.Substring($resumeMatch.Index).Trim()
      $cleaned = (($prefix + ' ' + $suffix).Trim() -replace '\s{2,}', ' ')
      continue
    }

    $cleaned = $cleaned.Substring(0, $startIndex).Trim()
    break
  }

  return $cleaned
}

function Clean-LxxVerseText {
  param([string]$Text)

  $cleaned = if ($null -eq $Text) { '' } else { [string]$Text }
  $cleaned = $cleaned -replace '\s+', ' '
  $cleaned = $cleaned.Trim()

  if (-not $cleaned) {
    return ''
  }

  $cleaned = Remove-EditorialSegment $cleaned
  $cleaned = $footnoteRunPattern.Replace($cleaned, ' ')
  $cleaned = $middleVerseNumberPattern.Replace($cleaned, ' ')
  $cleaned = $cleaned -replace '\b(?:NETS|NRSV|OLD GREEK|THEODOTION)\b', ' '
  $cleaned = $cleaned -replace '\s+([,.;:?!])', '$1'
  $cleaned = $cleaned -replace '\s{2,}', ' '
  $cleaned = $cleaned.Trim()

  if ($junkVersePattern.IsMatch($cleaned)) {
    return ''
  }

  $embeddedVerseMarkers = ([regex]::Matches($cleaned, '(?<!^)\b\d{1,3}(?:-\d{1,3})?\b')).Count
  if ($cleaned.Length -gt 900) {
    return ''
  }

  if ($cleaned.Length -gt 700 -and $embeddedVerseMarkers -ge 2) {
    return ''
  }

  return $cleaned
}

$updatedFiles = 0
$removedVerses = 0
$changedVerses = 0

$jsonFiles = Get-ChildItem -Path $resolvedSourceDir -Filter '*.json' | Sort-Object Name
foreach ($file in $jsonFiles) {
  $path = $file.FullName
  $raw = Get-Content -Raw -Encoding UTF8 -Path $path | ConvertFrom-Json
  $fileChanged = $false

  foreach ($chapter in $raw.chapters) {
    $newVerses = New-Object System.Collections.Generic.List[object]

    foreach ($verse in $chapter.verses) {
      $original = [string]$verse.text
      $cleaned = Clean-LxxVerseText $original

      if ([string]::IsNullOrWhiteSpace($cleaned)) {
        $removedVerses += 1
        $fileChanged = $true
        continue
      }

      if ($cleaned -ne $original) {
        $changedVerses += 1
        $fileChanged = $true
      }

      $verse.text = $cleaned
      $newVerses.Add($verse)
    }

    $chapter.verses = $newVerses.ToArray()
  }

  if ($fileChanged) {
    $updatedFiles += 1
    if (-not $WhatIf) {
      $json = $raw | ConvertTo-Json -Depth 100
      [System.IO.File]::WriteAllText($path, $json + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
    }
  }
}

Write-Output "Updated files: $updatedFiles"
Write-Output "Changed verses: $changedVerses"
Write-Output "Removed verses: $removedVerses"
