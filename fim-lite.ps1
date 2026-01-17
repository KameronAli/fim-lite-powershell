param(
  [Parameter(Mandatory)][ValidateSet("Baseline","Compare")]
  [string]$Mode,

  [Parameter(Mandatory)]
  [string]$Path,

  [string]$Baseline = ".\baseline.csv",
  [string]$Report   = ".\fim_report.csv",

  [string[]]$Exclude = @("*.tmp","*\AppData\Local\Temp\*")
)

function Test-Excluded($full, $patterns) {
  foreach ($p in $patterns) { if ($p -and ($full -like $p)) { return $true } }
  return $false
}

function Get-Snapshot($root, $exclude) {
  Get-ChildItem -Path $root -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-Excluded $_.FullName $exclude) } |
    ForEach-Object {
      $h = $null
      try { $h = (Get-FileHash -Algorithm SHA256 -Path $_.FullName -ErrorAction Stop).Hash } catch {}
      [pscustomobject]@{
        Path     = $_.FullName
        SHA256   = $h
        Size     = $_.Length
        MTimeUtc = $_.LastWriteTimeUtc.ToString("o")
      }
    }
}

$root = (Resolve-Path $Path).Path
$now  = (Get-Date).ToUniversalTime().ToString("o")

if ($Mode -eq "Baseline") {
  $snap = Get-Snapshot $root $Exclude
  $snap | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $Baseline
  Write-Host "Baseline saved: $Baseline  Files: $($snap.Count)"
  exit 0
}

# Compare mode
if (-not (Test-Path $Baseline)) { throw "Baseline not found: $Baseline" }

$base = Import-Csv $Baseline
$curr = Get-Snapshot $root $Exclude

$baseMap = @{}; foreach ($b in $base) { $baseMap[$b.Path] = $b }
$currMap = @{}; foreach ($c in $curr) { $currMap[$c.Path] = $c }

$events = New-Object System.Collections.Generic.List[object]

# Created + Modified
foreach ($p in $currMap.Keys) {
  if (-not $baseMap.ContainsKey($p)) {
    $events.Add([pscustomobject]@{ TimeUtc=$now; Type="Created";  Path=$p; OldSHA=$null; NewSHA=$currMap[$p].SHA256 })
  } else {
    $old = $baseMap[$p]; $new = $currMap[$p]
    if ($old.SHA256 -ne $new.SHA256) {
      $events.Add([pscustomobject]@{ TimeUtc=$now; Type="Modified"; Path=$p; OldSHA=$old.SHA256; NewSHA=$new.SHA256 })
    }
  }
}

# Deleted
foreach ($p in $baseMap.Keys) {
  if (-not $currMap.ContainsKey($p)) {
    $events.Add([pscustomobject]@{ TimeUtc=$now; Type="Deleted";  Path=$p; OldSHA=$baseMap[$p].SHA256; NewSHA=$null })
  }
}

$events | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $Report
Write-Host "Compare complete: $Report  Events: $($events.Count)"
