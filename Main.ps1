# Список программ
$programs = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "NanaZip"; Id = "M2Team.NanaZip" },
    @{ Name = "Notepad++"; Id = "Notepad++.Notepad++" }
)

# Проверяем, есть ли winget
$wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
if (-not $wingetCmd) {
    Write-Host "Команда winget не найдена в системе. Завершаем скрипт." -ForegroundColor Red
    exit
}

$wingetPath = $wingetCmd.Source

foreach ($program in $programs) {
    # Запрашиваем у пользователя установить ли программу
    $answer = Read-Host "Хотите установить '$($program.Name)'? (Y/N)"
    if ($answer -match '^[yY]') {
        Write-Host "Устанавливаю $($program.Name)..."
        Start-Process -FilePath $wingetPath -ArgumentList "install --id $($program.Id) --accept-package-agreements --accept-source-agreements" -Wait
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($program.Name) успешно установлен." -ForegroundColor Green
        }
        else {
            Write-Host "Ошибка при установке $($program.Name)." -ForegroundColor Red
        }
    }
    else {
        Write-Host "Пропускаю $($program.Name)."
    }
}
