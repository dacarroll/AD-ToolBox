#.ExternalHelp 'AD-ToolBox-help.xml'
foreach ($File in (Get-ChildItem "$PSScriptRoot\scripts" -Filter *.ps1 -Recurse)) {
    . $File.FullName
}