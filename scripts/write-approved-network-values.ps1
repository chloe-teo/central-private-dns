param(
    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$TerraformOutputJsonPath,

    [Parameter(Mandatory = $true)]
    [string]$DnsOutputPath,

    [Parameter(Mandatory = $true)]
    [string]$VnetOutputPath,

    [string]$ApprovedVnetLinksJsonPath = $null
)

function Merge-JsonMap {
    param(
        [hashtable]$Existing,
        [hashtable]$Incoming
    )

    foreach ($key in $Incoming.Keys) {
        if (-not $Existing.ContainsKey($key)) {
            $Existing[$key] = $Incoming[$key]
        }
    }

    return $Existing
}

$tfJsonContent = Get-Content -Path $TerraformOutputJsonPath -Raw
$terraformOutput = $tfJsonContent | ConvertFrom-Json -AsHashtable

$dnsOutput = [ordered]@{
    environment = $Environment
    approved_private_dns_zones = [ordered]@{}
    generated_at = (Get-Date -Format o)
    owner = "network-team"
}

if ($terraformOutput.ContainsKey('private_dns_zone_ids')) {
    $dnsMap = [ordered]@{}
    foreach ($key in $terraformOutput.private_dns_zone_ids.Keys) {
        $dnsMap[$key] = $terraformOutput.private_dns_zone_ids[$key]
    }
    $dnsOutput.approved_private_dns_zones = $dnsMap
}

if (Test-Path -Path $DnsOutputPath) {
    $existingDns = Get-Content -Path $DnsOutputPath -Raw | ConvertFrom-Json -AsHashtable
    if ($null -ne $existingDns -and $existingDns.ContainsKey('approved_private_dns_zones')) {
        $dnsOutput.approved_private_dns_zones = Merge-JsonMap -Existing ([ordered]@{}) -Incoming $existingDns.approved_private_dns_zones
        foreach ($key in $terraformOutput.private_dns_zone_ids.Keys) {
            if (-not $dnsOutput.approved_private_dns_zones.ContainsKey($key)) {
                $dnsOutput.approved_private_dns_zones[$key] = $terraformOutput.private_dns_zone_ids[$key]
            }
        }
    }
}

$directory = Split-Path -Parent $DnsOutputPath
if (-not (Test-Path -Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

$dnsOutput | ConvertTo-Json -Depth 8 | Set-Content -Path $DnsOutputPath

$vnetOutput = [ordered]@{
    environment = $Environment
    approved_vnet_links = [ordered]@{}
    generated_at = (Get-Date -Format o)
    owner = "network-team"
}

if ($ApprovedVnetLinksJsonPath -and (Test-Path -Path $ApprovedVnetLinksJsonPath)) {
    $existingVnet = Get-Content -Path $ApprovedVnetLinksJsonPath -Raw | ConvertFrom-Json -AsHashtable
    if ($null -ne $existingVnet -and $existingVnet.ContainsKey('approved_vnet_links')) {
        $vnetOutput.approved_vnet_links = [ordered]@{}
        foreach ($key in $existingVnet.approved_vnet_links.Keys) {
            $vnetOutput.approved_vnet_links[$key] = $existingVnet.approved_vnet_links[$key]
        }
    }
}

if ($terraformOutput.ContainsKey('approved_vnet_links')) {
    foreach ($key in $terraformOutput.approved_vnet_links.Keys) {
        if (-not $vnetOutput.approved_vnet_links.ContainsKey($key)) {
            $vnetOutput.approved_vnet_links[$key] = $terraformOutput.approved_vnet_links[$key]
        }
    }
}

$vnetDirectory = Split-Path -Parent $VnetOutputPath
if (-not (Test-Path -Path $vnetDirectory)) {
    New-Item -ItemType Directory -Path $vnetDirectory -Force | Out-Null
}

$vnetOutput | ConvertTo-Json -Depth 8 | Set-Content -Path $VnetOutputPath

Write-Host "Approved DNS values written to $DnsOutputPath"
Write-Host "Approved VNet values written to $VnetOutputPath"
