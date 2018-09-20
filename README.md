[![Build Status](https://travis-ci.org/luksi1/docker-mssql.svg?branch=master)](https://travis-ci.org/luksi1/powershell-osinfo)

# powershell-osinfo

## Description

Get disk and service information from the Common Infrastructure Model (CIM) via PowerShell

## Usage

### Disk information

Get-DiskInformation -ComputerName MYCOMPUTER

### Service Information

Get-ServiceInformation -ComputerName MYCOMPUTER

## Examples included in demo
- **Classes** - Validator for Active Directory. See .psm1 file. I'm not sure, outside of custom validators and DSC resource types, when a class would be needed. There might be a use case when using a specific type in a module, for example a PMP, Jira, or ServiceNow object. In these cases you might gain an advantage using a specific type over a PSCustomObject, since you could skip som validation logic. 
- **ArgumentCompleter** - The "ArgumentCompleter" is used for parameter handling. This can be a nice way to get optional arguments dynamically. Unfortunately, the arguments presented do not autocomplete. For instance, if, as in this example, you have 2000 Active Directory computers, and you typed bob, you wouldn't get all of the bob* computers. If you started scrolling, the autocompleter would simply start with the first element in the array. For large sets, perhaps using dynamic parameters is a more user friendly way to provide a dynamic set. See the function Get-ServiceInformation for an autocompleter example.
- **PSScriptAnalyzer** - Use Invoke-ScriptAnalyzer to check a module's compliancy. Note: You will need to install the module with Install-Module PSScriptAnalyzer before using this.
- **Pester** - Pester is the unit testing framework for PowerShell. It's structured similarly to Ruby's rspec. Invoke-Pester will run all tests under *.Tests.ps1 and the directory "tests". Se tests/OSInfo.Tests.ps1 for examples.
- **PlatyPS** - PlatyPS provides cmdlets for multi-language documentation with external help docs. PlatyPS allows module developers to put their documentation in markdown (.md) files, which then can be parsed and placed in locale specific .xml files. You can have as many locales as you want. The choice of locales, i.e. which language will be used, is decided by the locale of your shell. Note: This is an alternative to using in-line documentation.
- **Module manifest** - See the .psd1 file. Use New-ModuleManifest to create the skeleton manifest.
- **Functions** - Two functions are used in this demo.
- **DynamicParam** - Dynamic parameters allow you to use logic to dynamically alter or add parameters to your function. In this demo, I create a dynamic validation set. Notice that private functions are used! I began by adding the logic directly to the function, but noticed that I 1) would not be able to reuse this logic in additional functions and 2) would not be able to mock the dynamic set with Pester. 

## Additional examples, which were not covered in the class
- **Test stubs for Pester** - This is a nice way to run Pester tests when a module, or function, does not exist in your test environment. For instance, if your module needs the ActiveDirectory module, and this isn't available in your test environment, you could simply use a stub to overwrite the function. See tests\stubs\ActiveDirectoryStrub.psm1 for an example. I should even note that you cannot mock a function that does not exist in your environment. PowerShell will run a "validate command" method on all functions called in your .psm1 file before your Pester script is called. This "validate command" method will fail even if your function is mocked.
- **Exclusion rules for PSScriptAnalyzer using PSScriptAnalyzerSettings.psd1** - I didn't see any way to use in-line comments for exclusion rules for PSScript Analyzer. You can use exclusion rules on the command line (i.e. Invoke-ScriptAnalyzer -excluderule blablah), but then you loose consistency in your module. For instance, if someone else clones my module, there's no way that they would know which exclusion rules should be used. This allows for your exclusion rules to be defined within the module.
- **Continuous integration testing with Travis and Powershell Core in Docker** - For every push, we want to run our tests and this is where Travis comes in handy. Use GitLab runners, along with a .gitlab-ci.yml file, for GitLab continous integration. Notice the green "passing" box in the top of the module. This is scraped from Travis. 

## ToDo
- **parameter sets** (CMS handling | credentials)
- **formatting with format.ps1xml?** type extentions with type.ps1xml? I'm not sure how type.ps1xml could be used in this example.
- **add Appveyor and Gitlab CI as continuous integration examples**

## Examples from the class not included
- DSC - This doesn't really apply to PowerShell module development
- Custom classes - I can't see a use case for this here. See above under "classes" for an explanation about why I chose not to include these.