function Get-Setting {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Name,
    [Switch]$Encripted,
    $Path = (Join-Path $HOME .Settings)
)
    $Path = Resolve-Path $Path    
    if (Test-Path $Path){
        Write-Verbose "Read settings from $Path"
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))
        
        if ($Encripted){    
            DecriptValue $settings[$Name]
        } else {
            $settings[$Name]
        }               
    } else {
        Write-Verbose "Path $Path was not found."
    }
}

function Set-Setting {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Name,
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=1)]
    $Value,
    [Switch]$Encripted,
    $Path = (Join-Path $HOME .Settings)
)
    $Path = Resolve-Path $Path
    $settings = @{}
    if (Test-Path $Path){
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))
    }    
    if ($Encripted){    
        $settings[$Name] = EncriptValue $Value
    } else {
        $settings[$Name] = $Value
    }
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

function EncriptValue($value){
    Add-Type -AssemblyName System.Security
    $data = [Text.Encoding]::Default.GetBytes($value)    
    $encData = [Security.Cryptography.ProtectedData]::Protect($data, $null, "CurrentUser")
    [Convert]::ToBase64String($encData)
}

function DecriptValue($value){
    Add-Type -AssemblyName System.Security
    $encData = [Convert]::FromBase64String($value)        
    $data = [Security.Cryptography.ProtectedData]::Unprotect($encData, $null, "CurrentUser")    
    [Text.Encoding]::Default.GetString($data)
}


Export-ModuleMember `
    Get-Setting,
    Set-Setting