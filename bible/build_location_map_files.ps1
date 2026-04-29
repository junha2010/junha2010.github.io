$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$locationsJsonPath = Join-Path $root 'data\locations.json'
$locationsJsPath = Join-Path $root 'data\locations.js'

$newTestamentBooks = @(
  'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians',
  'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians',
  '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
  '1 John', '2 John', '3 John', 'Jude', 'Revelation'
)

$specificMaps = @{
  'Jerusalem' = @('jerusalem-map-crusades.jpg', '36 Israel During the Time of Jesus.png', '37 Israel During the Time of Acts.png')
  'Jericho' = @('jericho-madaba-detail.jpg', '13 The Conquest of Canaan Under Joshua.png', '09 The Promised Land.png')
  'Galilee' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png', '37 Israel During the Time of Acts.png')
  'Capernaum' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Bethsaida' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Tiberias' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Magdala' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Chorazin' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Gennesaret' = @('sea-of-galilee-1903.jpg', '36 Israel During the Time of Jesus.png')
  'Nazareth' = @('36 Israel During the Time of Jesus.png', '37 Israel During the Time of Acts.png')
  'Bethlehem' = @('18 The Kingdom of David.png', '36 Israel During the Time of Jesus.png')
  'Bethany' = @('36 Israel During the Time of Jesus.png', '37 Israel During the Time of Acts.png')
  'Samaria' = @('21 The Divided Kingdom.png', '36 Israel During the Time of Jesus.png', '37 Israel During the Time of Acts.png')
  'Judea' = @('36 Israel During the Time of Jesus.png', '27 Judah After the Return from Exile.png')
  'Damascus' = @('Syria.png', '39 Pauls First Missionary Journey.png')
  'Babylon' = @('24 The Babylonian Empire.png', '26 The Persian Empire.png')
  'Nineveh' = @('22 The Assyrian Empire.png', '01 The Near East.png')
  'Persia' = @('26 The Persian Empire.png', '25 The Median Empire.png')
  'Asia' = @('Asia.png', '38 The Mediterranean World During the Time of Acts.png')
  'Egypt' = @('Egypt.png', '08 Israels Exodus and Wanderings.png', '01 The Near East.png')
  'Syria' = @('Syria.png', '01 The Near East.png')
  'Rome' = @('33 The Roman Empire.png', '42 Pauls Journey to Rome.png')
  'Corinth' = @('40 Pauls Second Missionary Journey.png', '41 Pauls Third Missionary Journey.png')
  'Ephesus' = @('41 Pauls Third Missionary Journey.png', '43 The Churches of Revelation.png')
  'Philippi' = @('40 Pauls Second Missionary Journey.png', '38 The Mediterranean World During the Time of Acts.png')
  'Thessalonica' = @('40 Pauls Second Missionary Journey.png', '38 The Mediterranean World During the Time of Acts.png')
  'Athens' = @('40 Pauls Second Missionary Journey.png', '38 The Mediterranean World During the Time of Acts.png')
  'Malta' = @('42 Pauls Journey to Rome.png', '38 The Mediterranean World During the Time of Acts.png')
  'Patmos' = @('43 The Churches of Revelation.png', '38 The Mediterranean World During the Time of Acts.png')
}

function Add-UniqueMap {
  param(
    [System.Collections.Generic.List[string]]$Maps,
    [System.Collections.Generic.HashSet[string]]$Seen,
    [string]$Value
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return
  }

  if ($Seen.Add($Value)) {
    $Maps.Add($Value) | Out-Null
  }
}

function Get-ReferenceBooks {
  param([object[]]$References)

  $books = New-Object System.Collections.Generic.List[string]
  $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

  foreach ($reference in $References) {
    if ($reference -match '^(.*?) \d+:\d+') {
      $book = $matches[1].Trim()
      if ($seen.Add($book)) {
        $books.Add($book) | Out-Null
      }
    }
  }

  return @($books)
}

if (-not (Test-Path $locationsJsonPath)) {
  throw "Missing locations file: $locationsJsonPath"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$payload = Get-Content -Path $locationsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$newTestamentSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$newTestamentBooks | ForEach-Object { $newTestamentSet.Add($_) | Out-Null }

foreach ($entry in @($payload.locations)) {
  $maps = New-Object System.Collections.Generic.List[string]
  $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

  foreach ($map in @($specificMaps[$entry.name])) {
    Add-UniqueMap -Maps $maps -Seen $seen -Value $map
  }

  $referenceBooks = Get-ReferenceBooks -References @($entry.references)
  $hasNewTestament = $false
  $hasOldTestament = $false

  foreach ($book in $referenceBooks) {
    if ($newTestamentSet.Contains($book)) {
      $hasNewTestament = $true
    } else {
      $hasOldTestament = $true
    }
  }

  if ($hasOldTestament) {
    Add-UniqueMap -Maps $maps -Seen $seen -Value '09 The Promised Land.png'
    Add-UniqueMap -Maps $maps -Seen $seen -Value '05 The Land of Canaan.png'
    Add-UniqueMap -Maps $maps -Seen $seen -Value '01 The Near East.png'
  }

  if ($hasNewTestament) {
    Add-UniqueMap -Maps $maps -Seen $seen -Value '36 Israel During the Time of Jesus.png'
    Add-UniqueMap -Maps $maps -Seen $seen -Value '37 Israel During the Time of Acts.png'
    Add-UniqueMap -Maps $maps -Seen $seen -Value '38 The Mediterranean World During the Time of Acts.png'
  }

  if (-not $hasOldTestament -and -not $hasNewTestament) {
    Add-UniqueMap -Maps $maps -Seen $seen -Value '01 The Near East.png'
  }

  $entry | Add-Member -NotePropertyName map_files -NotePropertyValue @($maps | Select-Object -First 6) -Force
}

$json = $payload | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($locationsJsonPath, $json + [Environment]::NewLine, $utf8NoBom)
[System.IO.File]::WriteAllText($locationsJsPath, "window.BIBLE_LOCATIONS = $json;" + [Environment]::NewLine, $utf8NoBom)

Write-Output "Updated map_files for $(@($payload.locations).Count) locations."
