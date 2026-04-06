$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$versesJsonPath = Join-Path $root 'data\verses.json'
$dictionaryDir = Join-Path $root 'dictionary\krdict-reader-master\dict.entries.in'
$outputJsonPath = Join-Path $root 'data\word-meanings.json'
$outputJsPath = Join-Path $root 'data\word-meanings.js'

$stopwords = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@(
  'a','an','the','and','or','but','if','to','from','for','of','in','on','at','by','with','into','onto','upon','off',
  'out','up','down','over','under','through','across','about','after','before','between','among','around','against',
  'as','is','am','are','was','were','be','been','being','do','does','did','doing','have','has','had','having','will',
  'would','shall','should','may','might','must','can','could','not','no','nor','so','than','then','that','this','these',
  'those','there','their','them','they','he','him','his','she','her','hers','it','its','we','us','our','ours','you',
  'your','yours','i','me','my','mine','who','whom','whose','which','what','when','where','why','how','also','very',
  'all','any','both','each','few','more','most','other','some','such','only','own','same','too','just','now','here'
) | ForEach-Object { [void]$stopwords.Add($_) }

function Get-NormalizedWordCandidates {
    param([string]$Word)

    $raw = $Word.ToLowerInvariant()
    $candidates = New-Object System.Collections.Generic.List[string]
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    function Add-Candidate([string]$Value) {
        if ([string]::IsNullOrWhiteSpace($Value)) {
            return
        }
        if ($seen.Add($Value)) {
            [void]$candidates.Add($Value)
        }
    }

    Add-Candidate $raw

    if ($raw.EndsWith("'s")) {
        Add-Candidate $raw.Substring(0, $raw.Length - 2)
    }

    if ($raw.EndsWith("ies") -and $raw.Length -gt 3) {
        Add-Candidate ($raw.Substring(0, $raw.Length - 3) + 'y')
    }

    if ($raw.EndsWith("es") -and $raw.Length -gt 2) {
        Add-Candidate $raw.Substring(0, $raw.Length - 2)
    }

    if ($raw.EndsWith("s") -and $raw.Length -gt 1) {
        Add-Candidate $raw.Substring(0, $raw.Length - 1)
    }

    if ($raw.EndsWith("ing") -and $raw.Length -gt 4) {
        Add-Candidate $raw.Substring(0, $raw.Length - 3)
        Add-Candidate ($raw.Substring(0, $raw.Length - 3) + 'e')
    }

    if ($raw.EndsWith("ed") -and $raw.Length -gt 3) {
        Add-Candidate $raw.Substring(0, $raw.Length - 2)
        Add-Candidate ($raw.Substring(0, $raw.Length - 2) + 'e')
    }

    if ($raw.EndsWith("er") -and $raw.Length -gt 3) {
        Add-Candidate $raw.Substring(0, $raw.Length - 2)
    }

    if ($raw.EndsWith("est") -and $raw.Length -gt 4) {
        Add-Candidate $raw.Substring(0, $raw.Length - 3)
    }

    return $candidates
}

function Get-KoreanGloss {
    param([string]$EntryPath)

    $content = [System.IO.File]::ReadAllText($EntryPath, [System.Text.Encoding]::UTF8)
    $firstLine = ($content -split "<br>")[0]
    $decoded = [System.Net.WebUtility]::HtmlDecode($firstLine)
    $decoded = [regex]::Replace($decoded, '<[^>]+>', ' ')
    $decoded = [regex]::Replace($decoded, '\[[^\]]+\]', ' ')
    $decoded = [regex]::Replace($decoded, '\s+', ' ').Trim()
    if ([string]::IsNullOrWhiteSpace($decoded)) {
        return $null
    }

    $parts = $decoded -split ':'
    if ($parts.Count -lt 2) {
        return $null
    }

    $koreanPart = ($parts[1..($parts.Count - 1)] -join ':')
    $entries = $koreanPart -split ',' | ForEach-Object {
        ([regex]::Replace($_, '\s+', ' ')).Trim()
    } | Where-Object { $_ -and $_ -match '\p{IsHangulSyllables}' }

    $unique = New-Object System.Collections.Generic.List[string]
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($entry in $entries) {
        if ($seen.Add($entry)) {
            [void]$unique.Add($entry)
        }
    }

    if ($unique.Count -eq 0) {
        return $null
    }

    return ($unique -join ', ')
}

$versesData = Get-Content -Path $versesJsonPath -Raw | ConvertFrom-Json
$wordSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($bookProperty in $versesData.PSObject.Properties) {
    foreach ($chapterProperty in $bookProperty.Value.PSObject.Properties) {
        foreach ($verseText in $chapterProperty.Value) {
            foreach ($match in [regex]::Matches($verseText, "[A-Za-z]+(?:'[A-Za-z]+)?")) {
                $word = $match.Value.ToLowerInvariant()
                if ($word.Length -le 1 -or $stopwords.Contains($word)) {
                    continue
                }
                [void]$wordSet.Add($word)
            }
        }
    }
}

$dictionary = [ordered]@{}
$matchedCount = 0

foreach ($word in ($wordSet | Sort-Object)) {
    $matchPath = $null
    foreach ($candidate in Get-NormalizedWordCandidates -Word $word) {
        $candidatePath = Join-Path $dictionaryDir $candidate
        if (Test-Path $candidatePath) {
            $matchPath = $candidatePath
            break
        }
    }

    if (-not $matchPath) {
        continue
    }

    $gloss = Get-KoreanGloss -EntryPath $matchPath
    if (-not $gloss) {
        continue
    }

    $dictionary[$word] = $gloss
    $matchedCount++
}

$payload = [pscustomobject]@{
    word_count = $matchedCount
    words = [pscustomobject]$dictionary
}

$json = $payload | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outputJsonPath, $json, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($outputJsPath, "window.BIBLE_WORD_MEANINGS = $json;", [System.Text.UTF8Encoding]::new($false))

Write-Output "Matched $matchedCount Bible words and wrote $outputJsonPath"
