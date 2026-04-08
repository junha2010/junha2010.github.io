param(
  [int]$Limit = 0,
  [switch]$DownloadImages
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsJsonPath = Join-Path $root 'data\locations.json'
$outputJsonPath = Join-Path $root 'data\location-media.json'
$outputJsPath = Join-Path $root 'data\location-media.js'
$imageDir = Join-Path $root 'img\location'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$overrideQueries = @{
  'Eden' = @('Garden of Eden')
  'Galilee' = @('Sea of Galilee', 'Galilee')
  'Jerusalem' = @('Jerusalem')
  'Jericho' = @('Jericho')
  'Macedonia' = @('Macedonia (ancient kingdom)', 'Macedonia')
  'Edom' = @('Edom')
  'Nineveh' = @('Nineveh')
  'Babylon' = @('Babylon')
  'Nazareth' = @('Nazareth')
  'Bethlehem' = @('Bethlehem')
  'Bethany' = @('Bethany')
  'Capernaum' = @('Capernaum')
  'Bethsaida' = @('Bethsaida')
  'Magdala' = @('Magdala')
  'Tiberias' = @('Tiberias')
  'Gennesaret' = @('Gennesaret')
  'Corinth' = @('Corinth')
  'Ephesus' = @('Ephesus')
  'Philippi' = @('Philippi')
  'Thessalonica' = @('Thessaloniki', 'Thessalonica')
  'Athens' = @('Athens')
  'Rome' = @('Rome')
  'Malta' = @('Malta')
  'Patmos' = @('Patmos')
  'Damascus' = @('Damascus')
  'Egypt' = @('Egypt')
  'Syria' = @('Syria')
  'Assyria' = @('Assyria')
  'Persia' = @('Achaemenid Empire', 'Persia')
  'Sea of Galilee' = @('Sea of Galilee')
}

$placeKeywords = @(
  'city', 'town', 'village', 'region', 'river', 'sea', 'lake', 'mountain', 'mount',
  'valley', 'desert', 'island', 'province', 'territory', 'country', 'kingdom',
  'archaeological', 'site', 'settlement', 'fortress', 'harbor', 'port', 'biblical place',
  'ancient', 'located', 'capital'
)

$rejectKeywords = @(
  'person', 'family', 'genealogy', 'son of', 'daughter of', 'deity', 'god', 'goddess',
  'king of israel', 'judge of israel', 'companion of paul'
)

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
  if (-not $ascii) { return 'location' }
  return $ascii
}

function Invoke-JsonRequest {
  param([string]$Uri)

  return Invoke-RestMethod -Uri $Uri -Headers @{ 'User-Agent' = 'CodexBibleLocationMedia/1.0' }
}

function Get-SearchCandidates {
  param(
    [string]$Name,
    [string]$Description
  )

  $queries = New-Object System.Collections.Generic.List[string]
  foreach ($query in @($overrideQueries[$Name])) {
    if ($query) { $queries.Add($query) | Out-Null }
  }
  $queries.Add($Name) | Out-Null
  $queries.Add("$Name biblical location") | Out-Null

  $seenTitles = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
  $candidates = New-Object System.Collections.Generic.List[object]

  foreach ($query in $queries) {
    $encodedQuery = [uri]::EscapeDataString($query)
    $uri = "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$encodedQuery&format=json&utf8=1&srlimit=5"
    try {
      $response = Invoke-JsonRequest -Uri $uri
    } catch {
      continue
    }

    foreach ($item in @($response.query.search)) {
      if (-not $seenTitles.Add($item.title)) {
        continue
      }
      $candidates.Add([pscustomobject]@{
        title = $item.title
        snippet = $item.snippet
        source_query = $query
      }) | Out-Null
    }
  }

  return @($candidates | ForEach-Object { $_ })
}

function Test-Candidate {
  param(
    [string]$Name,
    [string]$Description,
    [object]$Candidate,
    [object]$Summary
  )

  $text = @(
    [string]$Candidate.snippet,
    [string]$Summary.extract,
    [string]$Description
  ) -join ' '
  $candidateTitle = [string]$Summary.title
  $sourceQuery = [string]$Candidate.source_query

  $normalizedName = $Name.ToLowerInvariant()
  $normalizedTitle = $candidateTitle.ToLowerInvariant()
  $normalizedQuery = $sourceQuery.ToLowerInvariant()

  foreach ($reject in $rejectKeywords) {
    if ($text -match [regex]::Escape($reject)) {
      return $false
    }
  }

  if ($normalizedName -eq 'eden' -and $candidateTitle -match 'Garden of Eden') {
    return $true
  }

  $titleLooksRight = $false
  if ($normalizedTitle -eq $normalizedName) {
    $titleLooksRight = $true
  } elseif ($normalizedTitle -match "(^|[\s,(])$([regex]::Escape($normalizedName))([\s),]|$)") {
    $titleLooksRight = $true
  } elseif ($normalizedQuery -and $normalizedTitle -eq $normalizedQuery) {
    $titleLooksRight = $true
  }

  if (-not $titleLooksRight) {
    return $false
  }

  $hasPlaceSignal = $false
  foreach ($keyword in $placeKeywords) {
    if ($text -match [regex]::Escape($keyword)) {
      $hasPlaceSignal = $true
      break
    }
  }

  return $hasPlaceSignal
}

function Get-PageSummary {
  param([string]$Title)

  $encodedTitle = [uri]::EscapeDataString($Title)
  $uri = "https://en.wikipedia.org/api/rest_v1/page/summary/$encodedTitle"
  try {
    return Invoke-JsonRequest -Uri $uri
  } catch {
    return $null
  }
}

if (-not (Test-Path $locationsJsonPath)) {
  throw "Missing locations file: $locationsJsonPath"
}

New-Item -ItemType Directory -Path $imageDir -Force | Out-Null

$payload = Get-Content -Path $locationsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$locations = @($payload.locations)
if ($Limit -gt 0) {
  $locations = $locations | Select-Object -First $Limit
}

$mediaEntries = New-Object System.Collections.Generic.List[object]

foreach ($entry in $locations) {
  $best = $null
  $summary = $null
  $searchResults = Get-SearchCandidates -Name $entry.name -Description ([string]$entry.description)

  foreach ($candidate in $searchResults) {
    $candidateSummary = Get-PageSummary -Title $candidate.title
    if ($null -eq $candidateSummary) {
      continue
    }
    if (-not $candidateSummary.thumbnail.source) {
      continue
    }
    if (Test-Candidate -Name $entry.name -Description ([string]$entry.description) -Candidate $candidate -Summary $candidateSummary) {
      $best = $candidate
      $summary = $candidateSummary
      break
    }
  }

  $imageFile = $null
  if ($DownloadImages -and $best -and $summary.thumbnail.source) {
    $ext = [IO.Path]::GetExtension(([uri]$summary.thumbnail.source).AbsolutePath)
    if (-not $ext) { $ext = '.jpg' }
    $fileName = "{0}{1}" -f (Convert-ToSlug $entry.name), $ext.ToLowerInvariant()
    $targetPath = Join-Path $imageDir $fileName
    try {
      Invoke-WebRequest -Uri $summary.thumbnail.source -OutFile $targetPath -Headers @{ 'User-Agent' = 'CodexBibleLocationMedia/1.0' } | Out-Null
      $imageFile = $fileName
    } catch {
      $imageFile = $null
    }
  }

  $mediaEntries.Add([pscustomobject]@{
    name = $entry.name
    page_title = if ($summary) { $summary.title } else { $null }
    page_url = if ($summary -and $summary.content_urls.desktop.page) { $summary.content_urls.desktop.page } else { $null }
    extract = if ($summary) { $summary.extract } else { $null }
    source_image_url = if ($summary -and $summary.thumbnail.source) { $summary.thumbnail.source } else { $null }
    local_image = $imageFile
  }) | Out-Null
}

$output = [pscustomobject]@{
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  count = $mediaEntries.Count
  entries = @($mediaEntries | ForEach-Object { $_ })
}

$json = $output | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($outputJsonPath, $json + [Environment]::NewLine, $utf8NoBom)
[IO.File]::WriteAllText($outputJsPath, "window.BIBLE_LOCATION_MEDIA = $json;" + [Environment]::NewLine, $utf8NoBom)

Write-Output "Wrote media manifest for $($mediaEntries.Count) locations."
