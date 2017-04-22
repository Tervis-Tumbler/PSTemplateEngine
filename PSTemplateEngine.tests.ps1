Import-Module -Force PSTemplateEngine

Describe "Template processing" {
    $TemplateFile = "$Home\TestDrive\Test.pstemplate"
@"
This is a template
`$Var
"@ | Out-File $TemplateFile -Force -Encoding default -NoNewline

    it "Confirm template file is the same as here string" {

    Get-Content $TemplateFile -Raw | Should Be @"
This is a template
`$Var
"@
}

    it "Inovoke-ProcessTemplateFile using locally scoped variable" {
        $Script:Var = "hello"
        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | Should Be @"
This is a template
hello
"@ 
    }

    it "Inovoke-ProcessTemplateFile global scope variable" {
        $Global:Var = "goodbye"       

        Invoke-ProcessTemplateFile -TemplateFile $TemplateFile | Should Be @"
This is a template
goodbye
"@ 

    }
}