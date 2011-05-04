function Get-Setting {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Name,
    $Path = (Join-Path $HOME .Settings)
)
    $Path = Resolve-Path $Path    
    if (Test-Path $Path){
        Write-Verbose "Read settings from $Path"
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))
        return $settings[$Name]
    } else {
        Write-Verbose "Path $Path was not found."
        return $null
    }
}

function Set-Setting {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Name,
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=1)]
    $Value,
    $Path = (Join-Path $HOME .Settings)
)
    $Path = Resolve-Path $Path
    $settings = @{}
    if (Test-Path $Path){
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))
    }    
    $settings[$Name] = $Value
    Write-Verbose "Write settings to $Path"
    Set-Content $Path (  ConvertToStringData $settings )
}

function ConvertToStringData($state){	
    $buffer = New-Object Text.StringBuilder 
    foreach($key in $state.Keys){
        $buffer.AppendLine( $key + "=" + $state[$key] ) | Out-Null
    }	
    $buffer
}


Export-ModuleMember `
    Get-Setting,
    Set-Setting