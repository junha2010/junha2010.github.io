$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceHtmlPath = Join-Path $root 'places_source.html'
$versesJsonPath = Join-Path $root 'data\verses.json'
$outputJsonPath = Join-Path $root 'data\locations.json'
$sourceUrl = 'https://bibleask.org/resources/bible-names/names-of-places-in-the-bible/'

function Remove-HtmlTags {
    param([string]$Value)

    if ($null -eq $Value) {
        return ''
    }

    return [regex]::Replace($Value, '<[^>]+>', '')
}

function Clean-Text {
    param([string]$Value)

    $decoded = [System.Net.WebUtility]::HtmlDecode((Remove-HtmlTags $Value))
    return ([regex]::Replace($decoded, '\s+', ' ')).Trim()
}

function Get-VerseText {
    param(
        [pscustomobject]$Lookup,
        [string]$Reference
    )

    $match = [regex]::Match($Reference, '^(.*?) (\d+):(\d+)$')
    if (-not $match.Success) {
        return $null
    }

    $book = $match.Groups[1].Value
    $chapter = $match.Groups[2].Value
    $verseNumber = [int]$match.Groups[3].Value

    $bookData = $Lookup.$book
    if ($null -eq $bookData) {
        return $null
    }

    $chapterData = $bookData.$chapter
    if ($null -eq $chapterData) {
        return $null
    }

    $verseIndex = $verseNumber - 1
    if ($verseIndex -lt 0 -or $verseIndex -ge $chapterData.Count) {
        return $null
    }

    return $chapterData[$verseIndex]
}

if (Test-Path $sourceHtmlPath) {
    $rawHtml = Get-Content -Path $sourceHtmlPath -Raw
} else {
    $response = Invoke-WebRequest -Uri $sourceUrl -UseBasicParsing
    $rawHtml = $response.Content
}

$versesLookup = Get-Content -Path $versesJsonPath -Raw | ConvertFrom-Json
$rows = [regex]::Matches($rawHtml, '<tr>(.*?)</tr>', 'IgnoreCase, Singleline')
$locations = New-Object System.Collections.Generic.List[object]

foreach ($row in $rows) {
    $cells = [regex]::Matches($row.Groups[1].Value, '<td>(.*?)</td>', 'IgnoreCase, Singleline')
    if ($cells.Count -ne 4) {
        continue
    }

    $name = Clean-Text $cells[0].Groups[1].Value
    if ([string]::IsNullOrWhiteSpace($name) -or $name -eq 'Name') {
        continue
    }

    $countText = Clean-Text $cells[1].Groups[1].Value
    $refsCell = $cells[2].Groups[1].Value
    $description = Clean-Text $cells[3].Groups[1].Value

    $refMatches = [regex]::Matches($refsCell, 'data-bibleask-ref="([^"]+)"', 'IgnoreCase')
    if ($refMatches.Count -eq 0) {
        continue
    }

    $references = New-Object System.Collections.Generic.List[string]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($refMatch in $refMatches) {
        $reference = $refMatch.Groups[1].Value
        if ($seen.Add($reference)) {
            [void]$references.Add($reference)
        }
    }

    $verses = foreach ($reference in $references) {
        [pscustomobject]@{
            reference = $reference
            text = Get-VerseText -Lookup $versesLookup -Reference $reference
        }
    }

    $occurrenceCount = 0
    if (-not [int]::TryParse($countText, [ref]$occurrenceCount)) {
        $occurrenceCount = $references.Count
    }

    $locations.Add(
        [pscustomobject]@{
            name = $name
            occurrence_count = $occurrenceCount
            references = @($references)
            verses = @($verses)
            description = $description
        }
    ) | Out-Null
}

$sortedLocations = $locations | Sort-Object name
$totalReferences = ($sortedLocations | ForEach-Object { $_.references.Count } | Measure-Object -Sum).Sum

$payload = [pscustomobject]@{
    source = $sourceUrl
    location_count = $sortedLocations.Count
    total_references = $totalReferences
    locations = @($sortedLocations)
}

$payload | ConvertTo-Json -Depth 8 | Set-Content -Path $outputJsonPath
Write-Output "Wrote $($sortedLocations.Count) locations to $outputJsonPath"
