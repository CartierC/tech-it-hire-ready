param(
    [string]$RootPath = "."
)

$ErrorActionPreference = "Stop"

Write-Host "Starting markdown link verification..."

$repoRoot = Resolve-Path $RootPath
$hasErrors = $false
$warningCount = 0
$errorCount = 0

# Find all markdown files except common junk/vendor folders
$markdownFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Include *.md | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]' -and
    $_.FullName -notmatch '[\\/]node_modules[\\/]' -and
    $_.FullName -notmatch '[\\/]vendor[\\/]'
}

if (-not $markdownFiles) {
    Write-Host "No markdown files found."
    exit 0
}

function Test-ExternalUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -MaximumRedirection 5 -TimeoutSec 15 -ErrorAction Stop
        return @{
            Success = $true
            StatusCode = [int]$response.StatusCode
            Message = "OK"
        }
    }
    catch {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method Get -MaximumRedirection 5 -TimeoutSec 15 -ErrorAction Stop
            return @{
                Success = $true
                StatusCode = [int]$response.StatusCode
                Message = "OK (GET fallback)"
            }
        }
        catch {
            $statusCode = $null
            $message = $_.Exception.Message

            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                $statusCode = [int]$_.Exception.Response.StatusCode
                $message = "HTTP $statusCode"
            }

            return @{
                Success = $false
                StatusCode = $statusCode
                Message = $message
            }
        }
    }
}

function Test-RelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,

        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    # Strip anchor if present
    $cleanTarget = $Target.Split('#')[0]

    if ([string]::IsNullOrWhiteSpace($cleanTarget)) {
        return $true
    }

    try {
        $joined = Join-Path -Path $BaseDirectory -ChildPath $cleanTarget
        return (Test-Path -LiteralPath $joined)
    }
    catch {
        return $false
    }
}

# Markdown inline link pattern: [text](link)
$linkPattern = '\[[^\]]+\]\(([^)]+)\)'

foreach ($file in $markdownFiles) {
    Write-Host "Scanning: $($file.FullName)"

    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue

    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Host "Skipping empty or unreadable file: $($file.FullName)"
        continue
    }

    $matches = [regex]::Matches($content, $linkPattern)

    if (-not $matches -or $matches.Count -eq 0) {
        continue
    }

    foreach ($match in $matches) {
        $link = $match.Groups[1].Value.Trim()

        if ([string]::IsNullOrWhiteSpace($link)) {
            continue
        }

        # Strip optional title text: [text](url "title")
        if ($link -match '^\s*(\S+)\s+".*"$') {
            $link = $matches[0].Groups[1].Value
        }

        # Remove surrounding angle brackets if present
        $link = $link.Trim('<', '>')

        # Ignore non-http navigational/safe schemes
        if (
            $link.StartsWith("#") -or
            $link.StartsWith("mailto:", [System.StringComparison]::OrdinalIgnoreCase) -or
            $link.StartsWith("tel:", [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            continue
        }

        # Ignore localhost/dev links as warnings, not failures
        if (
            $link -match '^https?://localhost' -or
            $link -match '^https?://127\.0\.0\.1'
        ) {
            Write-Warning "Local development link skipped in $($file.Name): $link"
            $warningCount++
            continue
        }

        if ($link -match '^https?://') {
            $result = Test-ExternalUrl -Url $link

            if ($result.Success) {
                Write-Host "PASS external: $link"
            }
            else {
                Write-Error "Broken external link in $($file.FullName): $link -- $($result.Message)"
                $hasErrors = $true
                $errorCount++
            }

            continue
        }

        # Treat everything else as relative path
        $baseDirectory = Split-Path -Parent $file.FullName
        $exists = Test-RelativePath -BaseDirectory $baseDirectory -Target $link

        if ($exists) {
            Write-Host "PASS relative: $link"
        }
        else {
            Write-Error "Broken relative link in $($file.FullName): $link"
            $hasErrors = $true
            $errorCount++
        }
    }
}

Write-Host ""
Write-Host "Link verification complete."
Write-Host "Warnings: $warningCount"
Write-Host "Errors: $errorCount"

if ($hasErrors) {
    exit 1
}

exit 0
