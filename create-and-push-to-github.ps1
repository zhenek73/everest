# create-and-push-to-github.ps1
# Скрипт создаёт репозиторий на GitHub (если его ещё нет) и пушит код.
# Запуск:  .\create-and-push-to-github.ps1

$ErrorActionPreference = 'Stop'

$owner = "zhenek73"
$repo  = "everest"
$remoteUrl = "https://github.com/$owner/$repo.git"

Write-Host "=== Everest Engineering → GitHub ===" -ForegroundColor Cyan
Write-Host "Владелец: $owner"
Write-Host "Репозиторий: $repo"
Write-Host ""

# 1. Запрашиваем токен безопасно
$secureToken = Read-Host "Вставь сюда свой Personal Access Token (ghp_...) " -AsSecureString
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
)

if (-not $token.StartsWith("ghp_")) {
    Write-Warning "Токен выглядит неправильно (должен начинаться с ghp_). Продолжаю на свой страх и риск..."
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept"        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# 2. Проверяем, существует ли уже репозиторий
Write-Host "Проверяю, существует ли репозиторий на GitHub..." -ForegroundColor Yellow
$repoCheckUrl = "https://api.github.com/repos/$owner/$repo"

try {
    $existing = Invoke-RestMethod -Uri $repoCheckUrl -Headers $headers -Method Get -ErrorAction Stop
    Write-Host "Репозиторий уже существует. Пропускаю создание." -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "Репозиторий не найден — создаю новый..." -ForegroundColor Yellow

        $createBody = @{
            name        = $repo
            description = "Статический сайт Эверест Инжиниринг — промышленные компоненты для конвейерной техники"
            private     = $false
            has_issues  = $true
            has_wiki    = $false
            auto_init   = $false   # важно! мы пушим свою историю
        } | ConvertTo-Json

        try {
            $created = Invoke-RestMethod -Uri "https://api.github.com/user/repos" `
                                         -Headers $headers `
                                         -Method Post `
                                         -Body $createBody `
                                         -ContentType "application/json"

            Write-Host "Репозиторий успешно создан: $($created.html_url)" -ForegroundColor Green
        } catch {
            Write-Error "Не удалось создать репозиторий: $($_.Exception.Message)"
            Write-Host "Возможно, у токена не хватает прав (нужен scope 'repo')." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Error "Ошибка при проверке репозитория: $($_.Exception.Message)"
        exit 1
    }
}

# 3. Убеждаемся, что remote origin настроен правильно
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote -ne $remoteUrl) {
    Write-Host "Настраиваю remote origin..." -ForegroundColor Yellow
    git remote remove origin 2>$null
    git remote add origin $remoteUrl
}

# 4. Пушим
Write-Host "Пушу код в репозиторий (это может занять время из-за изображений)..." -ForegroundColor Yellow

try {
    git push -u origin main

    Write-Host ""
    Write-Host "ГОТОВО!" -ForegroundColor Green
    Write-Host "Репозиторий: https://github.com/$owner/$repo" -ForegroundColor Cyan
    Write-Host "Через 1-2 минуты код появится на странице."
} catch {
    Write-Host ""
    Write-Host "Пуш не удался. Типичные причины:" -ForegroundColor Red
    Write-Host "  - Неправильный токен или нет прав 'repo'" -ForegroundColor Yellow
    Write-Host "  - Репозиторий уже существует и у тебя нет прав на запись" -ForegroundColor Yellow
    Write-Host "  - Проблемы с credential manager в Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Попробуй выполнить вручную:" -ForegroundColor Yellow
    Write-Host "  git push -u origin main" -ForegroundColor White
    Write-Host ""
    Write-Host "Или настрой credential helper:" -ForegroundColor Yellow
    Write-Host '  git config --global credential.helper manager' -ForegroundColor White
    exit 1
}

# 5. Полезные ссылки
Write-Host ""
Write-Host "Полезно дальше:" -ForegroundColor Cyan
Write-Host "  - Включи GitHub Pages: Settings → Pages → Source: main / (root)"
Write-Host "  - Добавь описание и topics в настройках репозитория"
Write-Host "  - Если нужно — создай ветку gh-pages для хостинга"
