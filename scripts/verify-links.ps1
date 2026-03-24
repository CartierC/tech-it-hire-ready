# verify-links.ps1
# Scans markdown files for URLs, checks each link, and writes a CSV report.

Write-Host "Starting markdown link verification..." -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$OutputFile = Join-Path $RepoRoot "link-report.csv"

$MarkdownFiles = Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
    $_.Extension -in @(".md", ".markdown")
}

if (-not $MarkdownFiles) {
    Write-Host "No markdown files found." -ForegroundColor Yellow
    exit 0
}

$LinkPattern = 'https?://[^\s\)\]">]+'
$Results = New-Object System.Collections.Generic.List[object]
$FoundLinks = 0
$FailedLinks = 0

foreach ($File in $MarkdownFiles) {
    Write-Host "Scanning: $($File.FullName)" -ForegroundColor Yellow

    $Content = Get-Content -Path $File.FullName -Raw
    $Matches = [regex]::Matches($Content, $LinkPattern)

    if ($Matches.Count -eq 0) {
        continue
    }

    $UniqueUrls = $Matches.Value | Sort-Object -Unique

    foreach ($Url in $UniqueUrls) {
        if ([string]::IsNullOrWhiteSpace($Url)) {
            continue
        }

        $FoundLinks++

        try {
            try {
                $Response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -MaximumRedirection 5 -ErrorAction Stop
            }
            catch {
                $Response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 10 -MaximumRedirection 5 -ErrorAction Stop
            }

            $StatusCode = [int]$Response.StatusCode

            $Results.Add([PSCustomObject]@{
                File   = $File.FullName.Replace($RepoRoot + [System.IO.Path]::DirectorySeparatorChar, "")
                URL    = $Url
                Status = "OK"
                Code   = $StatusCode
            })

            Write-Host "OK   $Url ($StatusCode)" -ForegroundColor Green
        }
        catch {
            $FailedLinks++

            $StatusCode = "N/A"
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
                try {
                    $StatusCode = [int]$_.Exception.Response.StatusCode
                }
                catch {
                    $StatusCode = "N/A"
                }
            }

            $Results.Add([PSCustomObject]@{
                File   = $File.FullName.Replace($RepoRoot + [System.IO.Path]::DirectorySeparatorChar, "")
                URL    = $Url
                Status = "FAIL"
                Code   = $StatusCode
            })

            Write-Host "FAIL $Url ($StatusCode)" -ForegroundColor Red
        }
    }
}

$Results | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host ""
Write-Host "Verification complete." -ForegroundColor Cyan
Write-Host "Total links checked: $FoundLinks" -ForegroundColor White
Write-Host "Failed links: $FailedLinks" -ForegroundColor White
Write-Host "Report saved to: $OutputFile" -ForegroundColor Cyan

if ($FailedLinks -gt 0) {
    exit 1
} else {
    exit 0
}