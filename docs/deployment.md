# Deployment

## Stack

| Компонент | Где |
|-----------|-----|
| App (web dyno) | Heroku Eco ($5/мес за 1000 dyno-часов всего) |
| База данных | Heroku Postgres `essential-0` ($5/мес) |
| Scheduler | Heroku Scheduler (бесплатный add-on, dyno-часы из общей квоты) |
| Source | GitHub: [mgrigoriev/moex-cache](https://github.com/mgrigoriev/moex-cache) |
| CI | GitHub Actions: rspec + rubocop + brakeman + bundler-audit |

**Итого:** ~$10/мес.

## Production app

- **Имя:** `moex-cache`
- **URL:** `https://moex-cache-ff34f14a1c26.herokuapp.com`
- **Region:** EU
- **Dashboard:** https://dashboard.heroku.com/apps/moex-cache

## Конфигурация

Env-переменные на Heroku:

| Var | Зачем |
|-----|-------|
| `API_KEY` | Авторизация эндпоинтов |
| `DATABASE_URL` | Автоматически от Postgres add-on |
| `SECRET_KEY_BASE` | Автогенерится Rails buildpack |

Просмотр: `heroku config`. Установка: `heroku config:set KEY=value`.

`API_KEY` сохранён в password manager под `moex-cache (Heroku production)`.

## Procfile

```
release: bin/rails db:migrate
web: bundle exec puma -C config/puma.rb
```

- **release phase** — запускается перед каждым деплоем, мигрирует БД
- **web** — единственный dyno, держит HTTP-сервер
- **worker dyno нет** — джобы триггерятся через Heroku Scheduler

## Scheduler

Открыть UI: `heroku addons:open scheduler`.

Расписание — каждый час, со смещением 10 минут между задачами:

| Время | Команда |
|-------|---------|
| `:00` | `bin/rails runner 'UpdateStocksJob.perform_now'` |
| `:10` | `bin/rails runner 'UpdateFundsJob.perform_now'` |
| `:20` | `bin/rails runner 'UpdateOfzJob.perform_now'` |
| `:30` | `bin/rails runner 'UpdateCorporateBondsJob.perform_now'` |
| `:40` | `bin/rails runner 'UpdateCurrenciesJob.perform_now'` |
| `:50` | `bin/rails runner 'UpdateImoexJob.perform_now; UpdateMoexbcJob.perform_now'` |
| daily 06:00 UTC | `bin/rails runner 'UpdateDividendForecastsJob.perform_now'` |

**Почему hourly, а не daily:** Heroku Scheduler — best-effort сервис, иногда молча скипает задачи. Hourly даёт самовосстановление: пропущенный тик подхватится через час. Стоимость пренебрежимая — ~3 сек × 24 = 72 сек dyno-time в день.

**Почему смещение 10 мин:** меньше нагрузки на MOEX за один момент, проще читать логи.

**Прогноз дивидендов** — отдельный daily-таск, потому что прогнозы меняются редко (~раз в квартал) и сам job делает ~50 HTTP-запросов с задержкой 1с (поминутный hourly бы зря жёг dyno-time). Время суток некритично, 06:00 UTC выбрано чтобы не пересекаться с активными часовыми тиками MOEX.

Heroku Scheduler ограничения:
- Daily — гранулярность 30 минут
- Hourly — гранулярность 10 минут (`:00`, `:10`, `:20`, `:30`, `:40`, `:50`)
- Минимальный интервал — every 10 minutes

## Деплой

При первом деплое было настроено **GitHub Integration → Automatic Deploys из main**. То есть:

```bash
git push   # → push в GitHub origin/main
           # → Heroku автоматически билдит и деплоит
           # → release phase запускает миграции
```

Никаких `git push heroku main` руками не нужно.

Проверить статус последнего деплоя: `heroku releases`.

## Что не задеплоено / отключено

- **Solid Queue worker** — не нужен (джобы через Scheduler)
- **Solid Queue scheduler** — `config/recurring.yml` используется только локально через `bin/dev`
- **ActionMailer / ActionMailbox / ActionCable** — закомментированы в `config/application.rb`, но гемы в lockfile (тянутся из meta-gem `rails`)
