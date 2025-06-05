Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Выберите программы для установки"
$form.Size = New-Object System.Drawing.Size(400,300)
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
    $checkbox.Location = New-Object System.Drawing.Point(20, (20 + ($i * 30)))
    $checkbox.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($checkbox)
    $checkboxes += $checkbox
}

$button = New-Object System.Windows.Forms.Button
$button.Text = "Установить"
$button.Size = New-Object System.Drawing.Size(100, 30)
$button.Location = New-Object System.Drawing.Point(140, (20 + ($programs.Count * 30)))
$form.Controls.Add($button)

# Обработчик кнопки с помощью Register-ObjectEvent (работает в PS 2.0)
$null = Register-ObjectEvent -InputObject $button -EventName Click -Action {
    # Получаем выбранные программы
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

    # Закрываем форму
    $form.Close()

    # Проверяем наличие winget
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetCmd) {
        [System.Windows.Forms.MessageBox]::Show("Команда winget не найдена в системе.")
        return
    }
    $wingetPath = $wingetCmd.Source

    foreach ($id in $selected) {
        Write-Host ("Устанавливаю {0}..." -f $id) -ForegroundColor Cyan
        # В PS2 нет try/catch, используем -ErrorAction и проверку вручную
        $proc = Start-Process -FilePath $wingetPath -ArgumentList "install --id $id --accept-package-agreements --accept-source-agreements" -Wait -PassThru -ErrorAction SilentlyContinue
        if ($proc.ExitCode -ne 0) {
            $msg = "Ошибка при установке $id"
            Write-Host $msg -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show($msg, "Ошибка", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
}

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()

# Отписываемся от события после закрытия формы, чтобы не было утечки
Unregister-Event -SourceIdentifier ($button.GetHashCode().ToString())
