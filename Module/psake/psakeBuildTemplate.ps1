properties {
<%
"    `$script = `"`$PSScriptRoot\$PLASTER_PARAM_ModuleName\$PLASTER_PARAM_ModuleName.psm1`""
%>
}
  
# Default task includes Analyzing and Testing of script
task default -depends Analyze, Test
  
# Analyze by running Invoke-ScriptAnalyzer. Check script against best known practices
task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'
    }
}
  
# Run our test to make sure everything is in line
task Test {
    $testResults = Invoke-Pester -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Tests') -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}
  
# Run a deployment script after appropriate tests are passed
task Deploy -depends Analyze, Test {
<%
"    Invoke-PSDeploy -Path '.\$PLASTER_PARAM_ModuleName.psdeploy.ps1' -Force -Verbose:`$VerbosePreference"
%>
}
  