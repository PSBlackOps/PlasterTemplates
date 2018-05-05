# Import functions, classes
<%
    $Directories = ''
    if ($PLASTER_PARAM_FunctionFolders -contains "Public") {
        $Directories += "'Public'"
    }
    if ($PLASTER_PARAM_FunctionFolders -contains "Private") {
        $Directories += ",'Private'"
    }
    if ($PLASTER_PARAM_FunctionFolders -contains "Classes") {
        $Directories += ",'Classes'"
    }
"`$ImportDirectories = `@($Directories)"
%>


# dot-source all the PowerShell scripts and classes into the $script: scope
foreach ($ImportDirectory in $ImportDirectories) {
    $DirectoryPath = Join-Path -Path $PSScriptRoot -ChildPath $ImportDirectory
    Write-Verbose ('Import directory: {0}' -f $ImportDirectory)

    if (Test-Path -Path $DirectoryPath) {
        Write-Verbose -Message ('Importing from: {0}' -f $DirectoryPath)
        $Imports = Get-ChildItem -Path $DirectoryPath -Filter '*.ps1'

        foreach ($Import in $Imports) {
            Write-Verbose ('{0}Importing: {1}' -f '`t', $Import.BaseName)
            . $($Import.FullName)
        }
    }
}


# Export PUBLIC functions
$PublicExports = (Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public') -Filter *.ps1).BaseName
Export-ModuleMember -Function $PublicExports