$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsJsonPath = Join-Path $root 'data\locations.json'
$locationsJsPath = Join-Path $root 'data\locations.js'
$referenceJsonPath = Join-Path $root 'data\wikipedia-biblical-places.json'
$mainWikiPath = Join-Path $root 'wikipedia-list-of-biblical-places.wiki'
$minorWikiPath = Join-Path $root 'wikipedia-list-of-minor-biblical-places.wiki'

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$manualAliasMap = @{
  'Accho' = @('Akko')
  'Accad' = @('Akkad')
  'Achaia' = @('Achaea')
  'Betshean' = @('Beit She''an', 'Beth Shean')
  'Dan' = @('Dan (formerly Laish)')
  'Eden' = @('Garden of Eden')
  'Judah' = @('Kingdom of Judah')
  'Kush' = @('Cush')
  'Laish' = @('Dan')
  'Rome' = @('Roman Empire')
  'Samaria' = @('Shomron')
}

$forceKeepNames = @(
  'Abarim',
  'Abelbethmaachah',
  'Abelmaim',
  'Abelmeholah',
  'Abelmizraim',
  'Abelshittim',
  'Abilene',
  'Aceldama',
  'Achmetha',
  'Adramyttium',
  'Aenon',
  'Alexandria',
  'Amphipolis',
  'Apollonia',
  'Arimathaea',
  'Armageddon',
  'Bethphage',
  'Bethzur',
  'Decapolis',
  'Emmaus',
  'Gennesaret',
  'Golgotha',
  'Havilah',
  'Nicopolis',
  'Perea',
  'Sharon',
  'Tarshish'
)

$forceDropNames = @(
  'Heaven',
  'Hell',
  'Jubilee',
  'Sheol'
)

$geoKeywordPatterns = @(
  '\bcity\b',
  '\btown\b',
  '\bvillage\b',
  '\bregion\b',
  '\bkingdom\b',
  '\bcountry\b',
  '\bprovince\b',
  '\bterritory\b',
  '\bland\b',
  '\bmountain\b',
  '\bhill country\b',
  '\bhill\b',
  '\bvalley\b',
  '\bplain\b',
  '\briver\b',
  '\bsea\b',
  '\bisland\b',
  '\bwilderness\b',
  '\bdesert\b',
  '\bcoastal\b',
  '\bcanal\b',
  '\bport\b',
  '\bborder\b',
  '\bencampment\b',
  '\bpass\b',
  '\bspring\b',
  '\bwell\b',
  '\brange\b'
)

$personIndicatorPatterns = @(
  '\bson of\b',
  '\bdaughter of\b',
  '\bfather of\b',
  '\bmother of\b',
  '\bancestor\b',
  '\bdescendant\b',
  '\bgenealogy\b',
  '\bperson\b',
  '\bman\b',
  '\bwoman\b',
  '\bchief god\b',
  '\bdeity\b',
  '\bcompanion of Paul\b',
  '\bpriest\b'
)

function Normalize-LocationName {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ''
  }

  $value = $Text.ToLowerInvariant()
  $value = [regex]::Replace($value, '\(.*?\)', ' ')
  $value = $value -replace '&nbsp;', ' '
  $value = [regex]::Replace($value, '[^a-z0-9]+', '')
  return $value
}

function Convert-WikiMarkupToPlainText {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ''
  }

  $value = $Text
  $value = $value -replace '<ref[^>]*>.*?</ref>', ''
  $value = $value -replace '{{[^{}]*}}', ''
  $value = $value -replace '\[\[(?:[^\]|]+\|)?([^\]]+)\]\]', '$1'
  $value = $value -replace "''+", ''
  $value = $value -replace '&nbsp;', ' '
  return ($value -replace '\s+', ' ').Trim()
}

function Add-ReferenceEntry {
  param(
    [hashtable]$Lookup,
    [string]$CanonicalName,
    [string[]]$Aliases,
    [string]$SourcePage
  )

  $canonicalName = [string]$CanonicalName
  if (-not [string]::IsNullOrWhiteSpace($canonicalName)) {
    $canonicalName = $canonicalName.Trim()
  }
  if ([string]::IsNullOrWhiteSpace($canonicalName)) {
    return
  }

  $canonicalKey = Normalize-LocationName $canonicalName
  if (-not $canonicalKey) {
    return
  }

  if (-not $Lookup.ContainsKey($canonicalKey)) {
    $Lookup[$canonicalKey] = [ordered]@{
      canonical_name = $canonicalName
      aliases = New-Object System.Collections.Generic.List[string]
      source_pages = New-Object System.Collections.Generic.HashSet[string]
    }
  }

  $entry = $Lookup[$canonicalKey]
  $entry.source_pages.Add($SourcePage) | Out-Null

  foreach ($alias in @($Aliases)) {
    $trimmed = [string]$alias
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
      continue
    }

    $trimmed = $trimmed.Trim()
    if ($trimmed -eq $canonicalName) {
      continue
    }

    if (-not ($entry.aliases -contains $trimmed)) {
      $entry.aliases.Add($trimmed) | Out-Null
    }
  }
}

function Get-NamesFromMainBullet {
  param([string]$Line)

  $clean = Convert-WikiMarkupToPlainText ($Line -replace '^\*\s*', '')
  if ([string]::IsNullOrWhiteSpace($clean)) {
    return @()
  }

  $left = (($clean -split '\s+[–-]\s+', 2)[0] | Select-Object -First 1)
  if ([string]::IsNullOrWhiteSpace($left)) {
    return @()
  }

  $names = New-Object System.Collections.Generic.List[string]
  $segments = @($left -split '/|\s+or\s+')

  foreach ($rawSegment in $segments) {
    $segment = [string]$rawSegment
    if ([string]::IsNullOrWhiteSpace($segment)) {
      continue
    }

    $segment = $segment.Trim()
    if ($segment -match '^(.*?)\s+\((?:formerly|also)\s+(.+?)\)$') {
      $first = [string]$matches[1]
      $second = [string]$matches[2]
      foreach ($part in @($first, $second)) {
        if ([string]::IsNullOrWhiteSpace($part)) {
          continue
        }

        $part = $part.Trim()
        if ($part -and -not ($names -contains $part)) {
          $names.Add($part) | Out-Null
        }
      }
      continue
    }

    if ($segment -and -not ($names -contains $segment)) {
      $names.Add($segment) | Out-Null
    }
  }

  return @($names | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-MinorHeadingName {
  param([string]$Line)

  if ($Line -notmatch '^===\s*(.+?)\s*===\s*$') {
    return $null
  }

  return (Convert-WikiMarkupToPlainText $matches[1])
}

function Test-AnyPattern {
  param(
    [string]$Text,
    [string[]]$Patterns
  )

  foreach ($pattern in $Patterns) {
    if ($Text -match $pattern) {
      return $true
    }
  }

  return $false
}

if (-not (Test-Path $mainWikiPath)) {
  throw "Missing Wikipedia source file: $mainWikiPath"
}

if (-not (Test-Path $minorWikiPath)) {
  throw "Missing Wikipedia source file: $minorWikiPath"
}

if (-not (Test-Path $locationsJsonPath)) {
  throw "Missing locations file: $locationsJsonPath"
}

$referenceLookup = @{}

Get-Content $mainWikiPath | ForEach-Object {
  if ($_ -match '^\*') {
    $line = [string]$_
    try {
      $names = @(Get-NamesFromMainBullet $line)
    } catch {
      $errorMessage = $_.Exception.Message
      throw "Failed to parse main Wikipedia line: $line`n$errorMessage"
    }
    if ($names.Count) {
      $aliases = if ($names.Count -gt 1) { @($names[1..($names.Count - 1)]) } else { @() }
      Add-ReferenceEntry -Lookup $referenceLookup -CanonicalName $names[0] -Aliases $aliases -SourcePage 'list_of_biblical_places'
    }
  }
}

Get-Content $minorWikiPath | ForEach-Object {
  $name = Get-MinorHeadingName $_
  if ($name) {
    Add-ReferenceEntry -Lookup $referenceLookup -CanonicalName $name -Aliases @() -SourcePage 'list_of_minor_biblical_places'
  }
}

$referenceEntries = foreach ($key in ($referenceLookup.Keys | Sort-Object)) {
  $entry = $referenceLookup[$key]
  [pscustomobject]@{
    canonical_name = $entry.canonical_name
    aliases = @($entry.aliases)
    source_pages = @($entry.source_pages | Sort-Object)
  }
}

$referencePayload = [pscustomobject]@{
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  sources = @(
    'https://en.wikipedia.org/wiki/List_of_biblical_places',
    'https://en.wikipedia.org/wiki/List_of_minor_biblical_places'
  )
  reference_count = $referenceEntries.Count
  entries = @($referenceEntries)
}

$referenceJson = $referencePayload | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText($referenceJsonPath, $referenceJson + [Environment]::NewLine, $utf8NoBom)

$referenceNameLookup = @{}
foreach ($entry in $referenceEntries) {
  $allNames = @($entry.canonical_name) + @($entry.aliases)
  foreach ($name in $allNames) {
    $normalized = Normalize-LocationName $name
    if (-not $referenceNameLookup.ContainsKey($normalized)) {
      $referenceNameLookup[$normalized] = New-Object System.Collections.Generic.List[object]
    }
    $referenceNameLookup[$normalized].Add($entry) | Out-Null
  }
}

$payload = Get-Content -Path $locationsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$originalLocations = @($payload.locations)
$removed = New-Object System.Collections.Generic.List[string]
$kept = New-Object System.Collections.Generic.List[object]

foreach ($entry in $originalLocations) {
  $name = [string]$entry.name
  $description = [string]$entry.description
  $normalized = Normalize-LocationName $name

  if ($forceDropNames -contains $name) {
    $removed.Add($name) | Out-Null
    continue
  }

  $matchingReferenceEntries = @()
  if ($referenceNameLookup.ContainsKey($normalized)) {
    $matchingReferenceEntries = @($referenceNameLookup[$normalized] | ForEach-Object { $_ })
  } elseif ($manualAliasMap.ContainsKey($name)) {
    foreach ($alias in $manualAliasMap[$name]) {
      $aliasKey = Normalize-LocationName $alias
      if ($referenceNameLookup.ContainsKey($aliasKey)) {
        $matchingReferenceEntries += @($referenceNameLookup[$aliasKey] | ForEach-Object { $_ })
      }
    }
  }

  $matchingReferenceEntries = @($matchingReferenceEntries | Select-Object -Unique)
  $hasWikiMatch = $matchingReferenceEntries.Count -gt 0
  $hasGeoDescription = Test-AnyPattern -Text $description -Patterns $geoKeywordPatterns
  $looksLikePerson = Test-AnyPattern -Text $description -Patterns $personIndicatorPatterns
  $shouldKeep = $hasWikiMatch -or ($forceKeepNames -contains $name) -or ($hasGeoDescription -and -not $looksLikePerson)

  if (-not $shouldKeep) {
    $removed.Add($name) | Out-Null
    continue
  }

  $aliases = New-Object System.Collections.Generic.List[string]

  foreach ($referenceEntry in $matchingReferenceEntries) {
    foreach ($candidate in @($referenceEntry.canonical_name) + @($referenceEntry.aliases)) {
      if ([string]::IsNullOrWhiteSpace($candidate)) {
        continue
      }

      $candidate = $candidate.Trim()
      if ($candidate -eq $name) {
        continue
      }

      if (-not ($aliases -contains $candidate)) {
        $aliases.Add($candidate) | Out-Null
      }
    }
  }

  foreach ($alias in @($manualAliasMap[$name])) {
    if ($alias -and -not ($aliases -contains $alias)) {
      $aliases.Add($alias) | Out-Null
    }
  }

  if ($aliases.Count) {
    $entry | Add-Member -NotePropertyName aliases -NotePropertyValue @($aliases) -Force
  } else {
    $entry.PSObject.Properties.Remove('aliases')
  }

  $kept.Add($entry) | Out-Null
}

$rebuiltPayload = [pscustomobject]@{
  source = 'https://en.wikipedia.org/wiki/List_of_biblical_places ; https://en.wikipedia.org/wiki/List_of_minor_biblical_places'
  source_note = 'Filtered and reconciled against the Wikipedia main and minor biblical places lists, with alias support for common Bible spellings.'
  location_count = $kept.Count
  total_references = (($kept | ForEach-Object { @($_.references).Count } | Measure-Object -Sum).Sum)
  locations = @($kept | ForEach-Object { $_ })
}

$locationsJson = $rebuiltPayload | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($locationsJsonPath, $locationsJson + [Environment]::NewLine, $utf8NoBom)
[System.IO.File]::WriteAllText($locationsJsPath, "window.BIBLE_LOCATIONS = $locationsJson;" + [Environment]::NewLine, $utf8NoBom)

Write-Output "Wikipedia reference entries: $($referenceEntries.Count)"
Write-Output "Kept locations: $($kept.Count)"
Write-Output "Removed locations: $($removed.Count)"
