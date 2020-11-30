function Get-VMMemoryReport {
    param(
        [Parameter(Mandatory=$True,HelpMessage="Provide report path", ValueFromPipeline = $true)]
        [string]$Path
    )
    Get-Vm | forEach ($_.Name) {Get-VMMemory $_.Name} | ConvertTo-HTML -Property VMName,DynamicMemoryEnabled,@{label=’MinimumSize(MB)’;expression={$_.minimum/1mb –as [int]}},@{label=’StartupSize(MB)’;expression={$_.startup/1mb –as [int]}},@{label=’MaximumSize(MB)’;expression={$_.maximum/1mb –as [int]}}> "$path\SimpleMemoryReport.htm"
}

function Get-VMDiskReport {
    param(
        [Parameter(Mandatory=$True,HelpMessage="Provide report path", ValueFromPipeline = $true)]
        [string]$Path
    )
    Get-Vm | forEach ($_.VMID) {Get-VHD $_.VMID} | ConvertTo-HTML -Property Path,ComputerName,VHDType,@{label=’Size(GB)’;expression={$_.filesize/1gb –as [int]}} > "$path\SimpleVHDReport.htm"
}

function Get-VMCPUReport {
    param(
        [Parameter(Mandatory=$True,HelpMessage="Provide report path", ValueFromPipeline = $true)]
        [string]$Path
    )
    Get-VM | forEach ($_.Name) {Get-VMProcessor $_.Name} | ConvertTo-Html -Property VMName,Count > "$path\SimpleCPUReport.htm"
}