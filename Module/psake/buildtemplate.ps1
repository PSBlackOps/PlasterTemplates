[cmdletbinding()]
param(
    [string[]]$Task = 'default' # This task is defined in psakeBuild. We are just setting a default here.
)

# Verify that we have PackageManagement module installed
if (!(Get-Command Install-Module)) {
    throw 'PackageManagement is not installed. You need V5 or https://www.microsoft.com/en-us/download/details.aspx?id=51451'
}

# Install any missing modules needed for build/test
if (!(Get-Module -Name Pester -ListAvailable)) {
    Install-Module -Name Pester -Scope CurrentUser
}
if (!(Get-Module -Name psake -ListAvailable)) {
    Install-Module -Name Psake -Scope CurrentUser
}
if (!(Get-Module -Name PSDeploy -ListAvailable)) {
    Install-Module -Name PSDeploy -Scope CurrentUser
}
if (!(Get-Module -Name PSScriptAnalyzer -ListAvailable)) {
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
}
if (!(Get-Module -Name platyPS -ListAvailable)) {
    Install-Module -Name platyPS -Scope CurrentUser
}

# Run our test
Invoke-Psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference
