# Список программ (название и id для winget)
$programs = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "NanaZip"; Id = "M2Team.NanaZip" },
    @{ Name = "Notepad++"; Id = "Notepad++.Notepad++" }
)

foreach ($program in $programs) {
    Write-Host "Хотите установить '$($program.Name)'? (Y/N)"
    $answer = Read-Host

    if ($answer.ToUpper() -eq "Y") {
        Write-Host "Устанавливаю $($program.Name)..."
        # Запускаем winget без проверки пути, предполагается, что он есть в PATH
        # Если winget нет, ошибка будет в консоли
        Start-Process -FilePath "winget" -ArgumentList "install --id $($program.Id) --accept-package-agreements --accept-source-agreements" -Wait
    }
    else {
        Write-Host "Пропускаю $($program.Name)."
    }
}
