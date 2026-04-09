Set-Location -Path $PSScriptRoot\..
& .\venv\Scripts\Activate.ps1
celery -A app.tasks.celery_app.celery_app worker --loglevel=info
