$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)
set-location $here
import-module PowerSpec
import-module .\PsConfig\PsConfig.psm1 -Force

test-spec { { 1 + 2 } | should not throw }

test-spec { 

    "Get predefined setting by name"
    
    { get-setting User -Path .\TestData\Simple.Settings } | should be_equal "user1" 

    "Set setting by name"
    { 
        $Path = [IO.Path]::GetTempFileName()
        set-setting User "user256" -Path $Path -Verbose
        get-setting User -Path $Path 
    } | should be_equal "user256"
}