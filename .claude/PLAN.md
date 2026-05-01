# План разработки MOEX Cache Service

## Фаза 1: Модели ✅
- [x] Stock + Fund (secid, market_price)
- [x] Ofz + CorporateBond (secid, short_name, market_price, ytm, duration, coupon_percent, coupon_period, maturity_date, face_value, accrued_interest)
- [x] Currency (secid, market_price) — фиксированный список тикеров: USD, EUR, CNY, AMD

## Фаза 2: Интеграция с MOEX API ✅
- [x] MoexClient в app/lib — fetch(url), parse(lines), fetch_bonds(marketdata_url, securities_url)
- [x] fetch_stocks (TQBR), fetch_funds (TQTF)
- [x] fetch_ofz (TQOB), fetch_corporate_bonds (TQCB)
- [x] fetch_currencies (CETS, фолбэк LAST → MARKETPRICE)
- [x] Кодировка ответа: Windows-1251 → UTF-8
- [x] Пропуск строк с пустым MARKETPRICE

## Фаза 3: Фоновые задачи ✅
- [x] Solid Queue на одной БД
- [x] Jobs: UpdateStocksJob, UpdateFundsJob, UpdateOfzJob, UpdateCorporateBondsJob, UpdateCurrenciesJob
- [x] Services: UpdateStocks, UpdateFunds, UpdateOfz, UpdateCorporateBonds, UpdateCurrencies
- [x] Расписание every 4h: stocks@0m, funds@3m, ofz@6m, corporate_bonds@9m, currencies@12m
- [x] bin/dev запускает web + worker через foreman + Procfile.dev

## Фаза 4: API эндпоинты ✅
- [x] GET /stocks.csv
- [x] GET /funds.csv
- [x] GET /ofz.csv
- [x] GET /corporate_bonds.csv
- [x] GET /currencies.csv
- [x] CSV сериализаторы в `app/serializers/csv/` под неймспейсом `Csv`
- [x] `Csv::BaseSerializer` — общая логика генерации CSV через `HEADERS.map { |f| record.public_send(f) }`

## Фаза 5: Тесты ✅
- [x] RSpec + shoulda-matchers + WebMock + factory_bot_rails
- [x] Фабрики в spec/factories/
- [x] Спеки моделей, сервисов, джобов, клиента, сериализаторов (48 примеров)
- [x] Rubocop (rubocop-rails-omakase) — без нарушений

## Фаза 6: Авторизация API ✅
- [x] API-ключ через GET-параметр `?api_key=...`
- [x] Хранение в env-переменной `API_KEY` (dotenv-rails локально, Heroku config vars в prod)
- [x] before_action в ApplicationController с `secure_compare`, 401 при невалидном/отсутствующем ключе

## Фаза 7: Деплой на Heroku

**Стратегия:** только web dyno + Heroku Scheduler (без отдельного worker dyno).
Recurring schedule в `config/recurring.yml` используется только локально через
foreman+solid_queue. На production cron'ы заводятся в Heroku Scheduler как
one-off dyno команды.

**План $5/мес Eco + $5/мес Postgres essential-0 = ~$10/мес.**

### Подготовка (локально)
- [x] Procfile создан (`release: bin/rails db:migrate`, `web: bundle exec puma -C config/puma.rb`)
- [ ] Закоммитить Procfile + push в main

### Heroku CLI и app
- [ ] `brew install heroku/brew/heroku` (если ещё нет)
- [ ] `heroku login`
- [ ] В Heroku UI: оплатить Eco plan ($5/мес), привязать карту
- [ ] `heroku create moex-cache-mgrigoriev --region eu` (имя глобально уникальное)
- [ ] `heroku addons:create heroku-postgresql:essential-0` (~$5/мес)
- [ ] `heroku addons:create scheduler:standard` (бесплатный)

### Конфигурация
- [ ] `heroku config:set API_KEY=$(openssl rand -hex 32)` — сохранить в password manager
- [ ] (опц.) `heroku config:set RAILS_LOG_LEVEL=info`
- [ ] Buildpack — Heroku сам определит Ruby по Gemfile, ничего настраивать не нужно

### Деплой
- [ ] `git push heroku main` (release phase запустит миграции)
- [ ] `heroku ps:scale web=1`
- [ ] `heroku open` → должна вернуться 401 на корне (auth работает)
- [ ] `curl -i "$(heroku info -s | grep web_url | cut -d= -f2)stocks.csv?api_key=..."`

### Heroku Scheduler — cron'ы для джобов
В `heroku addons:open scheduler` добавить 5 задач:
- [ ] `bin/rails runner 'UpdateStocksJob.perform_now'` — Every 6 hours @ :00
- [ ] `bin/rails runner 'UpdateFundsJob.perform_now'` — Every 6 hours @ :03
- [ ] `bin/rails runner 'UpdateOfzJob.perform_now'` — Every 6 hours @ :06
- [ ] `bin/rails runner 'UpdateCorporateBondsJob.perform_now'` — Every 6 hours @ :09
- [ ] `bin/rails runner 'UpdateCurrenciesJob.perform_now'` — Every 6 hours @ :12

(Heroku Scheduler даёт минимальный интервал 10 минут, доступны: every 10 min,
every hour, every day. Для "каждые 4 часа" возможно нужно использовать
`every hour` + проверку часа в коде, либо upgrade на add-on с гибким cron.
Альтернатива: Heroku Scheduler advanced, либо sidekiq cron.)

### Проверка
- [ ] Запустить любой джоб вручную: `heroku run "bin/rails runner 'UpdateStocksJob.perform_now'"`
- [ ] `heroku logs --tail` — следить за выполнением
- [ ] Проверить эндпоинт: `curl -i "https://APP.herokuapp.com/stocks.csv?api_key=..."`
- [ ] Подключить URL к Google Sheets через `=IMPORTDATA(...)`

## Надёжность
- [ ] Retry-логика в джобах при недоступности MOEX API (встроенный retry в ActiveJob или rescue с логированием)
- [ ] Кэширование ответов CSV эндпоинтов (Solid Cache, инвалидация после каждого успешного обновления)

## Будущие фазы
- Dividend (дивиденды) — парсинг Dohod.ru
