$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsPath = Join-Path $root 'data\locations.json'
$nivPath = Join-Path $root 'data\verses.json'
$kjvPath = Join-Path $root 'data\verses-kjv.json'
$lxxPath = Join-Path $root 'data\verses-lxx.json'
$outputJsonPath = Join-Path $root 'data\locations-by-translation.json'
$outputTxtPath = Join-Path $root 'data\location-names.txt'

$lxxCanonicalBookMap = @{
  'Kings I' = '1 Samuel'
  'Kings II' = '2 Samuel'
  'Kings III' = '1 Kings'
  'Kings IV' = '2 Kings'
  'Chronicles I' = '1 Chronicles'
  'Chronicles II' = '2 Chronicles'
  'Esdras I' = '1 Esdras'
  'Ezra and Nehemiah' = '2 Esdras'
  'Esther (Greek)' = 'Esther'
  'Maccabees I' = '1 Maccabees'
  'Maccabees II' = '2 Maccabees'
  'Maccabees III' = '3 Maccabees'
  'Maccabees IV' = '4 Maccabees'
  'Wisdom Of Jesus The Son Of Sirach (Ecclesiasticus)' = 'Sirach'
  'The Prayer of Manasses' = 'Prayer of Manasses'
  'Osee' = 'Hosea'
  'Obdias' = 'Obadiah'
  'Jonas' = 'Jonah'
  'Michæas' = 'Micah'
  'Naum' = 'Nahum'
  'Ambacum' = 'Habakkuk'
  'Sophonias' = 'Zephaniah'
  'Aggæus' = 'Haggai'
  'Zacharias' = 'Zechariah'
  'Malachias' = 'Malachi'
  'Esaias' = 'Isaiah'
  'Jeremias' = 'Jeremiah'
  'Epistle of Jeremy' = 'Letter of Jeremiah'
  'Jezekiel' = 'Ezekiel'
  'Daniel (Greek)' = 'Daniel'
}

function Build-LocationMatcher {
  param([string[]]$Names)

  $escapedNames = $Names |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object { $_.Length } -Descending |
    ForEach-Object { [regex]::Escape($_) }

  if (-not $escapedNames.Count) {
    return $null
  }

  $joined = $escapedNames -join '|'
  return [regex]::new("(?<![A-Za-z])(?:$joined)(?![A-Za-z])", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

function Get-CanonicalBookName {
  param(
    [string]$TranslationId,
    [string]$BookName
  )

  if ($TranslationId -eq 'lxx' -and $lxxCanonicalBookMap.ContainsKey($BookName)) {
    return $lxxCanonicalBookMap[$BookName]
  }

  return $BookName
}

function Add-Match {
  param(
    [hashtable]$TranslationMatches,
    [string]$LocationName,
    [string]$Reference,
    [string]$Text
  )

  if (-not $TranslationMatches.ContainsKey($LocationName)) {
    $TranslationMatches[$LocationName] = @{
      references = New-Object System.Collections.Generic.List[string]
      verses = New-Object System.Collections.Generic.List[object]
    }
  }

  $entry = $TranslationMatches[$LocationName]
  $entry.references.Add($Reference) | Out-Null
  $entry.verses.Add([pscustomobject]@{
    reference = $Reference
    text = $Text
  }) | Out-Null
}

function Scan-Translation {
  param(
    [string]$TranslationId,
    [pscustomobject]$Bundle,
    [regex]$Matcher,
    [hashtable]$LocationNameLookup
  )

  $translationMatches = @{}

  foreach ($bookProperty in $Bundle.PSObject.Properties) {
    $canonicalBookName = Get-CanonicalBookName -TranslationId $TranslationId -BookName $bookProperty.Name
    $bookData = $bookProperty.Value

    foreach ($chapterProperty in $bookData.PSObject.Properties) {
      $chapterNumber = $chapterProperty.Name
      $verses = @($chapterProperty.Value)

      for ($index = 0; $index -lt $verses.Count; $index++) {
        $verseText = [string]$verses[$index]
        if ([string]::IsNullOrWhiteSpace($verseText)) {
          continue
        }

        $seenInVerse = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($match in $Matcher.Matches($verseText)) {
          $matchedName = $match.Value
          if (-not $LocationNameLookup.ContainsKey($matchedName)) {
            continue
          }

          $canonicalLocationName = $LocationNameLookup[$matchedName]
          if (-not $seenInVerse.Add($canonicalLocationName)) {
            continue
          }

          $reference = '{0} {1}:{2}' -f $canonicalBookName, $chapterNumber, ($index + 1)
          Add-Match -TranslationMatches $translationMatches -LocationName $canonicalLocationName -Reference $reference -Text $verseText
        }
      }
    }
  }

  return $translationMatches
}

if (-not (Test-Path $locationsPath)) {
  throw "Missing locations source: $locationsPath"
}

$locationsPayload = Get-Content -Path $locationsPath -Raw | ConvertFrom-Json
$locationEntries = @($locationsPayload.locations)
$locationNames = @($locationEntries | ForEach-Object { $_.name })
$locationNameLookup = @{}
foreach ($name in $locationNames) {
  $locationNameLookup[$name] = $name
}

$matcher = Build-LocationMatcher -Names $locationNames
if ($null -eq $matcher) {
  throw 'Could not build location matcher.'
}

$bundles = @{
  niv = Get-Content -Path $nivPath -Raw | ConvertFrom-Json
  kjv = Get-Content -Path $kjvPath -Raw | ConvertFrom-Json
  lxx = Get-Content -Path $lxxPath -Raw | ConvertFrom-Json
}

$translationMatches = @{
  niv = Scan-Translation -TranslationId 'niv' -Bundle $bundles.niv -Matcher $matcher -LocationNameLookup $locationNameLookup
  kjv = Scan-Translation -TranslationId 'kjv' -Bundle $bundles.kjv -Matcher $matcher -LocationNameLookup $locationNameLookup
  lxx = Scan-Translation -TranslationId 'lxx' -Bundle $bundles.lxx -Matcher $matcher -LocationNameLookup $locationNameLookup
}

$combinedLocations = foreach ($location in ($locationEntries | Sort-Object name)) {
  $translations = [ordered]@{}
  $presentIn = New-Object System.Collections.Generic.List[string]
  $totalOccurrences = 0

  foreach ($translationId in @('niv', 'kjv', 'lxx')) {
    $matched = $translationMatches[$translationId][$location.name]
    $references = if ($matched) { @($matched.references | ForEach-Object { $_ }) } else { @() }
    $verses = if ($matched) { @($matched.verses | ForEach-Object { $_ }) } else { @() }
    $occurrenceCount = $references.Count
    $totalOccurrences += $occurrenceCount

    if ($occurrenceCount -gt 0) {
      $presentIn.Add($translationId) | Out-Null
    }

    $translations[$translationId] = [pscustomobject]@{
      occurrence_count = $occurrenceCount
      references = $references
      verses = $verses
    }
  }

  [pscustomobject]@{
    name = $location.name
    description = $location.description
    present_in = @($presentIn)
    present_in_all_three = ($presentIn.Count -eq 3)
    total_occurrences = $totalOccurrences
    translations = [pscustomobject]$translations
  }
}

$summary = [pscustomobject]@{
  niv = [pscustomobject]@{
    location_count = (@($combinedLocations | Where-Object { $_.translations.niv.occurrence_count -gt 0 })).Count
    total_occurrences = (($combinedLocations | ForEach-Object { $_.translations.niv.occurrence_count } | Measure-Object -Sum).Sum)
  }
  kjv = [pscustomobject]@{
    location_count = (@($combinedLocations | Where-Object { $_.translations.kjv.occurrence_count -gt 0 })).Count
    total_occurrences = (($combinedLocations | ForEach-Object { $_.translations.kjv.occurrence_count } | Measure-Object -Sum).Sum)
  }
  lxx = [pscustomobject]@{
    location_count = (@($combinedLocations | Where-Object { $_.translations.lxx.occurrence_count -gt 0 })).Count
    total_occurrences = (($combinedLocations | ForEach-Object { $_.translations.lxx.occurrence_count } | Measure-Object -Sum).Sum)
  }
}

$payload = [pscustomobject]@{
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  source_location_count = $locationEntries.Count
  summary = $summary
  locations = @($combinedLocations)
}

$payload | ConvertTo-Json -Depth 10 | Set-Content -Path $outputJsonPath
($combinedLocations | ForEach-Object { $_.name }) -join [Environment]::NewLine | Set-Content -Path $outputTxtPath

Write-Output "Wrote $($combinedLocations.Count) locations to $outputJsonPath"
Write-Output "Wrote plain text name list to $outputTxtPath"
