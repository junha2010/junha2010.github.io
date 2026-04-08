$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsJsonPath = Join-Path $root 'data\locations.json'
$locationsJsPath = Join-Path $root 'data\locations.js'

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$removeDescriptionPatterns = @(
  'refers to Herod Agrippa',
  'was one of the ten sons of',
  'is the firstborn son of',
  'is a descendant of',
  'was a descendant of',
  'was a Jebusite who owned',
  'is the name of a family',
  'chief god of',
  'one of Paul''s companions',
  'leader among the Levites',
  'the father of',
  'a person listed among',
  'a name listed in the genealogy of Jesus',
  'worshiped as the chief deity',
  'ancestor of one of the twelve tribes'
)

$removeExactNames = @(
  'Agrippa',
  'Amminadib',
  'Araunah',
  'Aridai',
  'Aridatha',
  'Arisai',
  'Aspatha',
  'Azgad',
  'Bel',
  'Cain',
  'Cainan',
  'Chemosh',
  'Crescens',
  'Darkon',
  'Eran',
  'Ginath',
  'Hagaba',
  'Hagabah',
  'Jorim',
  'Kadmiel',
  'Lysanias'
)

$keepExactNames = @(
  'Ariel',
  'Armageddon',
  'Asuppim',
  'Assyria',
  'Azzah',
  'Babel',
  'Bajith',
  'Bamah',
  'Bethesda',
  'Calvary',
  'Edar',
  'Edrei',
  'Eglaim',
  'Ekron',
  'Elbethel',
  'Eneglaim',
  'Enmishpat',
  'Ephratah',
  'Ephrath',
  'Gabbatha',
  'Gath',
  'Golgotha',
  'Gozan',
  'Grecia',
  'Gur',
  'Hadadrimmon',
  'Hamonah',
  'Hamongog',
  'Hara',
  'Hazarshual',
  'Hazeroth',
  'Hemath',
  'Heshmon',
  'Hobah',
  'Hoshaiah',
  'Idumea',
  'Irpeel',
  'Italy',
  'Jaazer',
  'Jahaza',
  'Jahazah',
  'Janum',
  'Jebus',
  'Jekabzeel',
  'Jeshimon',
  'Judea',
  'Karkor',
  'Kehelathah',
  'Kibrothhattaavah',
  'Kir',
  'Kirharaseth',
  'Kirioth',
  'Kirjath',
  'Kirjathbaal',
  'Kison',
  'Lachish',
  'Lakum',
  'Lebaoth',
  'Libya',
  'Lycia'
)

function Should-RemoveLocation {
  param(
    [string]$Name,
    [string]$Description
  )

  if ($keepExactNames -contains $Name) {
    return $false
  }

  if ($removeExactNames -contains $Name) {
    return $true
  }

  foreach ($pattern in $removeDescriptionPatterns) {
    if ($Description -match $pattern) {
      return $true
    }
  }

  return $false
}

if (-not (Test-Path $locationsJsonPath)) {
  throw "Missing locations file: $locationsJsonPath"
}

$payload = Get-Content -Path $locationsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$originalLocations = @($payload.locations)
$removed = New-Object System.Collections.Generic.List[string]

$filteredLocations = foreach ($entry in $originalLocations) {
  $description = [string]$entry.description
  if (Should-RemoveLocation -Name $entry.name -Description $description) {
    $removed.Add($entry.name) | Out-Null
    continue
  }

  $entry
}

$payload.location_count = @($filteredLocations).Count
$payload.total_references = ((@($filteredLocations) | ForEach-Object { @($_.references).Count } | Measure-Object -Sum).Sum)
$payload.locations = @($filteredLocations)

$json = $payload | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($locationsJsonPath, $json + [Environment]::NewLine, $utf8NoBom)
[System.IO.File]::WriteAllText($locationsJsPath, "window.BIBLE_LOCATIONS = $json;" + [Environment]::NewLine, $utf8NoBom)

Write-Output "Removed $($removed.Count) non-location entries."
Write-Output ($removed | Sort-Object | Select-Object -First 80)
