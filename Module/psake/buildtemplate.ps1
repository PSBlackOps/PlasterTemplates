[cmdletbinding()]
param(
    [string[]]$Task = 'default' # This task is defined in psakeBuild. We are just setting a default here.
)

# Verify that we have PackageManagement module installed
if (!(Get-Command Install-Module)) {
    throw 'PackageManagement is not installed. You need V5 or https://www.microsoft.com/en-us/download/details.aspx?id=51451'
}

$Modules = @(
    'Pester',
    'Psake',
    'PSDeploy',
    'PSScriptAnalyzer',
    'platyPS'
)
# Taken from Brandon Padgett's Resolve-Module
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
foreach ($Module in $Modules) {
    $Installed = Get-Module -Name $Module -ListAvailable
    Write-Verbose -Message ('Resolving module: {0}' -f $Module)

    if ($Installed) {
        $Version = $Installed | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
        $GalleryVersion = Find-Module -Name $Module -Repository PSGallery | Measure-Object -Property Version -Maximum

        if ($Version -lt $GalleryVersion) {
            Write-Verbose -Message "$($Module) Installed Version [$($Version.tostring())] is outdated. Installing Gallery Version [$($GalleryVersion.tostring())]"

            Install-Module -Name $Module -Force
            Import-Module -Name $Module -Force -RequiredVersion $GalleryVersion
        }
        else {
            Write-Verbose -Message ('{0} installed. Importing.' -f $Module)
            Import-Module -Name $Module -Force -RequiredVersion $Version
        }
    }
    else {
        Write-Verbose -Message ('{0} missing. Installing.' -f $Module)
        Install-Module -Name $Module -Force

        $Installed = Get-Module -Name $Module -ListAvailable
        $Version = $Installed | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
        Import-Module -Name $Module -Force -RequiredVersion $Version
    }

}

# Run our test
Invoke-Psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference
