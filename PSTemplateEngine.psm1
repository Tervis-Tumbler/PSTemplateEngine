#Requires -Version 5
function Invoke-ProcessTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]$Template
        #,$Data
    )

    $TemplateAsSingleString = Get-Content $Template | Out-String
    $TemplateHereString = @"
@"
$TemplateAsSingleString
"`@
"@

    $TemplateAfterProcessing = Invoke-Expression $TemplateHereString

    Compare-Object $($TemplateAsSingleString -split '\n') $($TemplateAfterProcessing -split '\n') | fl * | Out-String -Stream | Write-Verbose

    $TemplateAfterProcessing
}