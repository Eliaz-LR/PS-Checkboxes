#INSPIRED BY https://github.com/LarsVomMars/Checkboxes

class CheckboxOptions {
    [int]$Index
    [string]$Option
    [bool]$Selected
    [bool]$Hovered

    CheckboxOptions([string]$option, [bool]$selected, [bool]$hovered, [int]$index) {
        $this.Option = $option
        $this.Selected = $selected
        $this.Hovered = $hovered
        $this.Index = $index
    }

    [CheckboxReturn] GetData() {
        return [CheckboxReturn]::new($this.Index, $this.Option)
    }
}

class CheckboxReturn {
    [int]$Index
    [string]$Option

    CheckboxReturn([int]$index, [string]$option) {
        $this.Index = $index
        $this.Option = $option
    }
}

class Checkbox {
    [Collections.Generic.List[CheckboxOptions]]$Options
    [int]$HoveredIndex = 0
    [int]$SelectedIndex = -1
    [string]$DisplayText
    [bool]$MultiSelect
    [bool]$Required
    [bool]$Error

    Checkbox([string]$displayText, [bool]$multiMode, [bool]$required, [string[]]$options) {
        $this.MultiSelect = $multiMode
        $this.Required = $required
        $this.Init($displayText, $options)
    }

    Checkbox([string]$displayText, [string[]]$options) {
        $this.MultiSelect = $true
        $this.Required = $true
        $this.Init($displayText, $options)
    }

    [void]Init([string]$dt, [string[]]$options) {
        $this.DisplayText = $dt
        $this.Options = [System.Collections.Generic.List[CheckboxOptions]]::new()
        for ($i = 0; $i -lt $options.Length; $i++) {
            $this.Options.Add([CheckboxOptions]::new($options[$i], $false, $i -eq $this.HoveredIndex, $i))
        }
    }

    [CheckboxReturn[]] ReturnData() {
        $returnList = @()
        foreach ($option in $this.Options) {
            if ($option.Selected) {
                $returnList += $option.GetData()
            }
        }
        return $returnList
    }

    [void] Show() {
        Clear-Host
        Write-Host $this.DisplayText
        Write-Host "(Use Arrow keys to navigate up and down, Space bar to select and Enter to submit)"

        foreach ($option in $this.Options) {
            if ($option.Hovered) {
                $color = if ($option.Selected) { "Cyan" } else { "White" }
            }
            else {
                $color = if ($option.Selected) { "Blue" } else { "DarkGray" }
            }
            Write-Host ("$(if ($option.Selected)  {"[*]"} else {"[ ]"})~ $($option.Option)" ) -ForegroundColor $color
        }

        if ($this.Error) { Write-Host "`nAt least one item has to be selected!" -ForegroundColor Red }
    }

    [CheckboxReturn[]] Select() {
        $this.Show()
        $end = $false
        do {
            $key = $global:Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 38) {
                # Up Arrow
                $this.Options[$this.HoveredIndex].Hovered = $false
                $this.HoveredIndex = if ($this.HoveredIndex - 1 -ge 0) { $this.HoveredIndex - 1 } else { $this.Options.Count - 1 }
            }
            elseif ($key.VirtualKeyCode -eq 40) {
                # Down Arrow
                $this.Options[$this.HoveredIndex].Hovered = $false
                $this.HoveredIndex = if ($this.HoveredIndex + 1 -lt $this.Options.Count) { $this.HoveredIndex + 1 } else { 0 }
            }
            elseif ($key.VirtualKeyCode -eq 32) {
                # Space
                $this.Options[$this.HoveredIndex].Selected = -not $this.Options[$this.HoveredIndex].Selected
                if (-not $this.MultiSelect) {
                    if ($this.SelectedIndex -ge 0 -and $this.HoveredIndex -ne $this.SelectedIndex) {
                        $this.Options[$this.SelectedIndex].Selected = $false
                    }
                    $this.SelectedIndex = $this.HoveredIndex
                }
                $this.Error = $false
            }
            elseif ($key.VirtualKeyCode -eq 13) {
                # Enter
                if ($this.Required) {
                    $end = ($this.Options | Where-Object { $_.Selected } | Measure-Object).Count -gt 0
                    if (-not $end) { $this.Error = $true }
                }
                else {
                    $end = $true
                }
            }
            $this.Options[$this.HoveredIndex].Hovered = $true
            $this.Show()
        } while (-not $end)
        return $this.ReturnData()
    }
}
