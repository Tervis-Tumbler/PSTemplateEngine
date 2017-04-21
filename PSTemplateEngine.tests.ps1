Import-Module -Force PSTemplateEngine

Describe "Template processing" {
    $TemplateFile = "$TestDrive\Test.pstemplate"
@"
This is a template
`$Var
"@ | Out-File $TemplateFile -Force
    
    it "compares template" {

        Get-Content -Path $TemplateFile | Should Be @"
This is a template
`$Var
"@
}

    it "Inovoke-ProcessTemplateFile" {
        get-content $TemplateFile
        Set-Variable -Name var -Value "hello"

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | Should Be @"
This is a template
hello
"@ 
    }
    it "Inovoke-ProcessTemplateFile global scope variable" {
        $Global:Var = "Hello"       

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | Should Be @"
This is a template
hello
"@ 

    }
}