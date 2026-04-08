param(
  [int]$Limit = 0,
  [int]$PerLocation = 2,
  [switch]$DownloadImages,
  [switch]$OverwriteExisting
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsJsonPath = Join-Path $root 'data\locations.json'
$referenceJsonPath = Join-Path $root 'data\wikipedia-biblical-places.json'
$existingMediaJsonPath = Join-Path $root 'data\location-media.json'
$outputJsonPath = if ($Limit -gt 0) { Join-Path $root 'data\location-media.preview.json' } else { Join-Path $root 'data\location-media.json' }
$outputJsPath = if ($Limit -gt 0) { Join-Path $root 'data\location-media.preview.js' } else { Join-Path $root 'data\location-media.js' }
$reportJsonPath = if ($Limit -gt 0) { Join-Path $root 'data\location-media-report.preview.json' } else { Join-Path $root 'data\location-media-report.json' }
$imageDir = Join-Path $root 'img\location'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$mapKeywords = @('map', 'plan', 'atlas', 'survey', 'biblica', 'biblical', 'ancient')
$rejectKeywords = @('flag', 'coat of arms', 'locator', 'location map', 'logo', 'seal', 'portrait', 'painting', 'fresco', 'relief', 'coin', 'statue')

$searchOverrides = @{
  'Eden' = @('Garden of Eden')
  'Accho' = @('Akko')
  'Accad' = @('Akkad')
  'Macedonia' = @('Macedonia ancient kingdom')
  'Judah' = @('Kingdom of Judah')
  'Sea of Galilee' = @('Sea of Galilee')
  'Galilee' = @('Sea of Galilee', 'Galilee')
  'Megiddo' = @('Tel Megiddo')
  'Ephesus' = @('Ephesus')
  'Jerusalem' = @('Jerusalem')
  'Jericho' = @('Jericho')
}

function Normalize-Name {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ''
  }

  return ([regex]::Replace($Text.ToLowerInvariant(), '[^a-z0-9]+', ''))
}

function Convert-ToSlug {
  param([string]$Value)

  $normalized = $Value.Normalize([Text.NormalizationForm]::FormD)
  $chars = foreach ($char in $normalized.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
      $char
    }
  }

  $ascii = -join $chars
  $ascii = $ascii -replace '[^A-Za-z0-9]+', '-'
  $ascii = $ascii.Trim('-').ToLowerInvariant()
  if (-not $ascii) {
    return 'location'
  }

  return $ascii
}

function Invoke-WikiJson {
  param([string]$Uri)

  return Invoke-RestMethod -Uri $Uri -Headers @{ 'User-Agent' = 'CodexBibleMapBuilder/1.0' }
}

function Get-ReferenceAliasLookup {
  param([object]$ReferencePayload)

  $lookup = @{}
  foreach ($entry in @($ReferencePayload.entries)) {
    $allNames = @($entry.canonical_name) + @($entry.aliases)
    foreach ($name in $allNames) {
      $normalized = Normalize-Name $name
      if (-not $normalized) {
        continue
      }

      if (-not $lookup.ContainsKey($normalized)) {
        $lookup[$normalized] = New-Object System.Collections.Generic.List[string]
      }

      foreach ($candidate in $allNames) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
          continue
        }

        if (-not ($lookup[$normalized] -contains $candidate)) {
          $lookup[$normalized].Add($candidate) | Out-Null
        }
      }
    }
  }

  return $lookup
}

function Get-LocationSearchTerms {
  param(
    [object]$LocationEntry,
    [hashtable]$ReferenceAliasLookup
  )

  $terms = New-Object System.Collections.Generic.List[string]

  foreach ($term in @($searchOverrides[[string]$LocationEntry.name])) {
    if ($term -and -not ($terms -contains $term)) {
      $terms.Add($term) | Out-Null
    }
  }

  foreach ($term in @($LocationEntry.name) + @($LocationEntry.aliases)) {
    if ($term -and -not ($terms -contains $term)) {
      $terms.Add([string]$term) | Out-Null
    }
  }

  $normalized = Normalize-Name ([string]$LocationEntry.name)
  foreach ($term in @($ReferenceAliasLookup[$normalized])) {
    if ($term -and -not ($terms -contains $term)) {
      $terms.Add([string]$term) | Out-Null
    }
  }

  return @($terms | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Search-CommonsMapCandidates {
  param(
    [string]$SearchTerm,
    [int]$Limit = 8
  )

  $queries = @(
    "`"$SearchTerm`" map",
    "`"$SearchTerm`" biblical map",
    "`"$SearchTerm`" ancient map",
    "`"$SearchTerm`" plan"
  )

  $results = New-Object System.Collections.Generic.List[object]
  $seenTitles = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

  foreach ($query in $queries) {
    $encodedQuery = [uri]::EscapeDataString($query)
    $uri = "https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrnamespace=6&gsrlimit=$Limit&gsrsearch=$encodedQuery&prop=imageinfo&iiprop=url|size|mime&iiurlwidth=1400&format=json&utf8=1"

    try {
      $response = Invoke-WikiJson -Uri $uri
    } catch {
      continue
    }

    $pages = @($response.query.pages.PSObject.Properties | ForEach-Object { $_.Value })
    foreach ($page in $pages) {
      $title = [string]$page.title
      if (-not $seenTitles.Add($title)) {
        continue
      }

      $imageInfo = @($page.imageinfo)[0]
      if ($null -eq $imageInfo -or -not $imageInfo.thumburl) {
        continue
      }

      $results.Add([pscustomobject]@{
        query = $query
        title = $title
        url = [string]$imageInfo.url
        thumburl = [string]$imageInfo.thumburl
        mime = [string]$imageInfo.mime
        width = [int]$imageInfo.width
        height = [int]$imageInfo.height
      }) | Out-Null
    }
  }

  return @($results | ForEach-Object { $_ })
}

function Get-CandidateScore {
  param(
    [string]$LocationName,
    [string[]]$Aliases,
    [object]$Candidate
  )

  $title = ([string]$Candidate.title).ToLowerInvariant()
  $score = 0

  foreach ($reject in $rejectKeywords) {
    if ($title -like "*$reject*") {
      return -1000
    }
  }

  foreach ($keyword in $mapKeywords) {
    if ($title -like "*$keyword*") {
      $score += 12
    }
  }

  $needles = @($LocationName) + @($Aliases)
  foreach ($needle in $needles) {
    if ([string]::IsNullOrWhiteSpace($needle)) {
      continue
    }

    $normalizedNeedle = Normalize-Name $needle
    if (-not $normalizedNeedle) {
      continue
    }

    if ((Normalize-Name $title).Contains($normalizedNeedle)) {
      $score += 22
    }
  }

  if ($Candidate.mime -match 'svg|png|jpeg') {
    $score += 4
  }

  if ($Candidate.width -ge 900 -and $Candidate.height -ge 600) {
    $score += 3
  }

  return $score
}

function Get-BestCommonsCandidates {
  param(
    [object]$LocationEntry,
    [hashtable]$ReferenceAliasLookup,
    [int]$PerLocation
  )

  $searchTerms = Get-LocationSearchTerms -LocationEntry $LocationEntry -ReferenceAliasLookup $ReferenceAliasLookup
  $candidates = New-Object System.Collections.Generic.List[object]
  $seenTitles = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

  foreach ($term in $searchTerms) {
    foreach ($candidate in Search-CommonsMapCandidates -SearchTerm $term) {
      if (-not $seenTitles.Add($candidate.title)) {
        continue
      }

      $score = Get-CandidateScore -LocationName ([string]$LocationEntry.name) -Aliases @($LocationEntry.aliases) -Candidate $candidate
      if ($score -lt 10) {
        continue
      }

      $candidates.Add([pscustomobject]@{
        score = $score
        title = $candidate.title
        url = $candidate.url
        thumburl = $candidate.thumburl
        mime = $candidate.mime
        query = $candidate.query
      }) | Out-Null
    }
  }

  return @($candidates | Sort-Object score -Descending | Select-Object -First $PerLocation)
}

function Get-FileExtensionFromCandidate {
  param([object]$Candidate)

  $ext = [IO.Path]::GetExtension(([uri]$Candidate.url).AbsolutePath)
  if ($ext) {
    return $ext.ToLowerInvariant()
  }

  switch -Regex ($Candidate.mime) {
    'png' { return '.png' }
    'svg' { return '.svg' }
    'jpeg|jpg' { return '.jpg' }
    default { return '.jpg' }
  }
}

if (-not (Test-Path $locationsJsonPath)) {
  throw "Missing locations file: $locationsJsonPath"
}

if (-not (Test-Path $referenceJsonPath)) {
  throw "Missing Wikipedia reference file: $referenceJsonPath"
}

New-Item -ItemType Directory -Path $imageDir -Force | Out-Null

$locationsPayload = Get-Content -Path $locationsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$referencePayload = Get-Content -Path $referenceJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$referenceAliasLookup = Get-ReferenceAliasLookup -ReferencePayload $referencePayload
$locations = @($locationsPayload.locations)

if ($Limit -gt 0) {
  $locations = @($locations | Select-Object -First $Limit)
}

$existingMediaLookup = @{}
if ((Test-Path $existingMediaJsonPath) -and -not $OverwriteExisting) {
  $existingPayload = Get-Content -Path $existingMediaJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($entry in @($existingPayload.entries)) {
    $existingMediaLookup[[string]$entry.name] = $entry
  }
}

$mediaEntries = New-Object System.Collections.Generic.List[object]
$reportEntries = New-Object System.Collections.Generic.List[object]

foreach ($location in $locations) {
  $existingEntry = $existingMediaLookup[[string]$location.name]
  if ($existingEntry -and @($existingEntry.files).Count) {
    $mediaEntries.Add([pscustomobject]@{
      name = $location.name
      files = @($existingEntry.files)
    }) | Out-Null

    $reportEntries.Add([pscustomobject]@{
      name = $location.name
      status = 'kept-existing'
      files = @($existingEntry.files)
      candidates = @()
    }) | Out-Null
    continue
  }

  $candidates = Get-BestCommonsCandidates -LocationEntry $location -ReferenceAliasLookup $referenceAliasLookup -PerLocation $PerLocation
  $downloadedFiles = New-Object System.Collections.Generic.List[string]

  if ($DownloadImages) {
    $index = 0
    foreach ($candidate in $candidates) {
      $index += 1
      $ext = Get-FileExtensionFromCandidate -Candidate $candidate
      $fileName = if ($index -eq 1) {
        "{0}{1}" -f (Convert-ToSlug ([string]$location.name)), $ext
      } else {
        "{0}-{1}{2}" -f (Convert-ToSlug ([string]$location.name)), $index, $ext
      }

      $targetPath = Join-Path $imageDir $fileName
      try {
        Invoke-WebRequest -Uri $candidate.url -OutFile $targetPath -Headers @{ 'User-Agent' = 'CodexBibleMapBuilder/1.0' } | Out-Null
        $downloadedFiles.Add($fileName) | Out-Null
      } catch {
        continue
      }
    }
  }

  if ($downloadedFiles.Count) {
    $mediaEntries.Add([pscustomobject]@{
      name = $location.name
      files = @($downloadedFiles)
    }) | Out-Null
  }

  $reportEntries.Add([pscustomobject]@{
    name = $location.name
    status = if ($downloadedFiles.Count) { 'downloaded' } elseif ($candidates.Count) { 'candidates-found' } else { 'no-map-found' }
    files = @($downloadedFiles)
    candidates = @($candidates | ForEach-Object {
      [pscustomobject]@{
        title = $_.title
        query = $_.query
        url = $_.url
        score = $_.score
      }
    })
  }) | Out-Null
}

$output = [pscustomobject]@{
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  source = 'Wikimedia Commons map search seeded from Wikipedia biblical place references'
  count = $mediaEntries.Count
  entries = @($mediaEntries | ForEach-Object { $_ })
}

$report = [pscustomobject]@{
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  count = $reportEntries.Count
  entries = @($reportEntries | ForEach-Object { $_ })
}

$json = $output | ConvertTo-Json -Depth 8
$reportJson = $report | ConvertTo-Json -Depth 8
[IO.File]::WriteAllText($outputJsonPath, $json + [Environment]::NewLine, $utf8NoBom)
[IO.File]::WriteAllText($outputJsPath, "window.BIBLE_LOCATION_MEDIA = $json;" + [Environment]::NewLine, $utf8NoBom)
[IO.File]::WriteAllText($reportJsonPath, $reportJson + [Environment]::NewLine, $utf8NoBom)

Write-Output "Wrote location media for $($mediaEntries.Count) locations."
Write-Output "Wrote report for $($reportEntries.Count) locations."
