# MOEX Cache

Rails 8.1 API-only сервис, который ежедневно подтягивает данные с Московской биржи и отдаёт их CSV-эндпоинтами для подключения к Google Sheets через `=IMPORTDATA()`.

## Зачем

MOEX ISS API периодически недоступен — это ломает аналитику инвестиционного портфеля. Этот сервис кеширует актуальные данные у себя в БД и отдаёт их даже когда MOEX лежит.

## Что внутри

- **5 категорий данных:** акции, фонды, ОФЗ, корпоративные облигации, валюты
- **5 CSV-эндпоинтов** с авторизацией по API-ключу
- **Daily scheduler** обновляет данные раз в сутки в 08:00 UTC
- **Heroku** — production, $10/мес (Eco dynos + Postgres essential-0)

## Production

- **App:** [moex-cache](https://dashboard.heroku.com/apps/moex-cache)
- **Base URL:** `https://moex-cache-ff34f14a1c26.herokuapp.com`
- **GitHub:** [mgrigoriev/moex-cache](https://github.com/mgrigoriev/moex-cache)

## Документация

| Файл | Содержание |
|------|------------|
| [api.md](api.md) | Эндпоинты, авторизация, формат ответа |
| [architecture.md](architecture.md) | Структура кода, как добавить новую модель |
| [deployment.md](deployment.md) | Heroku setup, инфраструктура, стоимость |
| [operations.md](operations.md) | Повседневные команды: deploy, logs, scheduler, env vars |

## Quick start (локально)

```bash
bundle install
bin/rails db:setup
cp .env.example .env  # API_KEY=local-dev-key
bin/dev               # web + Solid Queue worker
```

```bash
# Прогнать обновление вручную
bin/rails runner 'UpdateStocksJob.perform_now'

# Проверить эндпоинт
curl 'http://localhost:3000/stocks.csv?api_key=local-dev-key'

# Тесты
bundle exec rspec
```
