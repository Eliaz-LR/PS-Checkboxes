. ".\Checkbox.ps1"

$choices = @("Option 1", "Option 2", "Option3")
$checkboxHeadline = "Select one of the following options"

$checkbox = [Checkbox]::new($checkboxHeadline, <#multiMode#> $true, <#required#> $true, $choices)
$result = $checkbox.Select()

$result | ForEach-Object { Write-Host "Selected: $($_.Option)" }