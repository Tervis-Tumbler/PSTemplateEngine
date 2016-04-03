#Requires -Version 5
function Invoke-ProcessTemplateFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]$TemplateFile
        #,$Data
    )

    $TemplateAsSingleString = Get-Content $TemplateFile | Out-String
    $TemplateHereString = @"
@"
$TemplateAsSingleString
"`@
"@

    $TemplateAfterProcessing = Invoke-Expression $TemplateHereString

    Compare-Object $($TemplateAfterProcessing -split '\n') $($TemplateAsSingleString -split '\n') | fl * | Out-String -Stream | Write-Verbose

    $TemplateAfterProcessing
}