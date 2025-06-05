Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Выберите программы для установки"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

$programs = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "NanaZip"; Id = "M2Team.NanaZip" },
    @{ Name = "Notepad++"; Id = "Notepad++.Notepad++" }
)

$checkboxes = @()

for ($i = 0; $i -lt $programs.Count; $i++) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $programs[$i].Name
    $checkbox.Location = New-Object System.Drawing.Point(20, 20 + ($i * 30))
    $checkbox.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($checkbox)
    $checkboxes += $checkbox
}

$button = New-Object System.Windows.Forms.Button
$button.Text = "Установить"
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Location = New-Object System.Drawing.Point(140, 20 + ($programs.Count * 30))

$button.Add_Click({
    $selected = @()
    for ($i = 0; $i -lt $checkboxes.Count; $i++) {
        if ($checkboxes[$i].Checked) {
            $selected += $programs[$i].Id
        }
    }

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Выберите хотя бы одну программу.")
        return
    }

    $form.Close()

    $wingetCommand = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetCommand) {
        Write-Host "Ошибка: winget не найден в системе." -ForegroundColor Red
        return
    }

    foreach ($id in $selected) {
        Write-Host ("Устанавливаю {0}..." -f $id) -ForegroundColor Cyan
        try {
            Start-Process -NoNewWindow -Wait -FilePath "winget" -ArgumentList "install --id $id --accept-package-agreements --accept-source-agreements"
        }
        catch {
            Write-Host ("Ошибка при установке {0}: {1}" -f $id, $_.Exception.Message) -ForegroundColor Red
        }
    }
})

$form.Controls.Add($button)
$form.Topmost = $true
$form.ShowDialog()
