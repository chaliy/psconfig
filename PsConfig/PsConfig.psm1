function Get-Setting {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
    [String]$Name,
    [Switch]$Encripted,
    $Path = (Join-Path $HOME .Settings),
    [String]$Prompt
)    
    if (Test-Path $Path){
        $Path = Resolve-Path $Path
        Write-Verbose "Read settings from $Path"
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))        
        if ($Encripted){                
            $value = [string]$settings[$Name]            
            if ($value -ne ""){
                $value = DecriptValue $value
            }
        } else {
            $value = $settings[$Name]
        }               
    } else {
        Write-Verbose "Path $Path was not found."
    }
    
    if ($Prompt -ne "" -and ($value -eq "" -or $value -eq $null)){                
        $value = Read-Host $Prompt
        Set-Setting $Name $value -Encripted:$Encripted -Path:$Path
    }
    
    [string]$value
<#
.Synopsis
    Gets configuration setting from user folder or elsewhere.
.Description 
    The Get-Setting function gets value for given setting name. By default it uses home directory and file .Settings, but you can specify path to another file.
    The Get-Setting uses INI-like format compatible with ConvertFrom-StringData, however later possible that this will change.
    Additionally the Get-Setting function supports decripting values (encription/decription is provided by Data Protection API (DPAPI) and by default uses UserScope).
    
    NOTE: If you are using Get-Setting and Set-Setting with encription, be ware that values encripted by Data Protection API (DPAPI) could be decripted by another program that runs under user's scope.    
.Parameter Name
    Name of the setting to get. Try to use ASCII char set and refuse special chars. This function does not provide any fool proof.
    
.Parameter Encripted
    Indicates that value will be decripted with Data Protection API (DPAPI) after retrieve.
    
.Parameter Path
    Optional parameter, specifyies path to file with settings.    
.Link
    https://github.com/chaliy/psconfig
.Link
    Set-Setting
    
.Example
    Get-Setting User

    Description
    -----------
    Retrieves value from default settings file under the name User. Default settings file is $home\.Settings
    
.Example
    Get-Setting User -Encripted

    Description
    -----------
    Retrieves encripted with Data Protection API (DPAPI) value from default settings file under the name User
    
#>
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
    $settings = @{}
    if (Test-Path $Path){
        $Path = Resolve-Path $Path
        $settings = ConvertFrom-StringData ([IO.File]::ReadAllText($Path))
    }    
    if ($Encripted){    
        $settings[$Name] = EncriptValue $Value
    } else {
        $settings[$Name] = $Value
    }
    Write-Verbose "Write settings to $Path"
    Set-Content $Path (  ConvertToStringData $settings )
<#
.Synopsis
    Sets configuration setting to user folder or elsewhere.
.Description 
    The Set-Setting function sets value for given setting name. By default it uses home directory and file .Settings, but you can specify path to another file.
    The Set-Setting uses INI-like format compatible with ConvertFrom-StringData, however later possible that this will change.
    Additionally the Set-Setting function supports encripting values (encription/decription is provided by Data Protection API (DPAPI) and by default uses UserScope).
    
    NOTE: If you are using Set-Setting and Set-Setting with encription, be ware that values encripted by Data Protection API (DPAPI) could be decripted by another program that runs under user's scope.    
.Parameter Name
    Name of the setting to store. Try to use ASCII char set and refuse special chars. This function does not provide any fool proof.
    
.Parameter Value
    Value of the setting to store. Try to use ASCII char set and refuse special chars. This function does not provide any fool proof.
    
.Parameter Encripted
    Indicates that value will be encripted with Data Protection API (DPAPI) before save.
    
.Parameter Path
    Optional parameter, specifyies path to file with settings.    
.Link
    https://github.com/chaliy/psconfig
.Link
    Get-Setting
    
.Example
    Set-Setting User user256

    Description
    -----------
    Store value "user256" to default settings file under the name User. Default settings file is $home\.Settings
    
.Example
    Set-Setting User user256 -Encripted

    Description
    -----------
    Store encripted with Data Protection API (DPAPI) value "user256" to default settings file under the name User
    
#>
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