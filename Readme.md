PsConfig Utils
=============

Set of commands to read/write simple settings.

Features
========

1. Read/Write simple values under user's scope
2. Protect presisted values with Data Protection API (DPAPI)

Examples
========

Most simple example is

    set-setting User user256 # Save setting
    get-setting User # Retrieve setting
    
To protect data, use Encripted swtich

    set-setting User user256 -Encripted # Save setting
    get-setting User -Encripted # Retrieve setting

Installation
============

With <a href="https://github.com/chaliy/psget">PsGet</a>, execute:

    install-module PsConfig
    
And you are ready to go.
   
FAQ
===

Q: Is protected settings are really protected?

A: PsConfig uses Data Protection API (DPAPI) under user scope to protect values. This means that value is protected from other people, but not from you or other program that runs on your behalf.


Credits
=======

1. PsConfig uses PowerSpec to automate testing.  