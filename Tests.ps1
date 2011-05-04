$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)
set-location $here
import-module PowerSpec
import-module .\PsConfig\PsConfig.psm1 -Force

test-spec {
    "When reading predefined setting by name"    
    $result = get-setting User -Path .\TestData\Simple.Settings;
    $result | should be_equal "user1"     
}

test-spec {     
    "When setting value by name"
    $Path = [IO.Path]::GetTempFileName()
    set-setting User "user256" -Path $Path -Verbose
    $Result = get-setting User -Path $Path 
    
    $Result | should be_equal "user256"
}

test-spec {    
    "When setting couple values by names"
    
    $Path = [IO.Path]::GetTempFileName()
    set-setting User "user256" -Path $Path -Verbose
    set-setting User2 "user257" -Path $Path -Verbose
    set-setting User3 "user258" -Path $Path -Verbose    
    $User = get-setting User -Path $Path;
    $User2 = get-setting User2 -Path $Path;
    $User3 = get-setting User3 -Path $Path
        
    $User | should be_equal user256
    $User2 | should be_equal user257
    $User3 | should be_equal user258
}

test-spec {    
    "When setting encripted value"
    
    $Path = [IO.Path]::GetTempFileName()
    set-setting User "user256" -Encripted -Path $Path -Verbose    
    $Result = get-setting User -Encripted -Path $Path;
        
    $Result | should be_equal user256
}