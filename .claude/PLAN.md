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
- [ ] Heroku CLI, app, postgres add-on
- [ ] Heroku config: API_KEY, RAILS_MASTER_KEY (если будут credentials)
- [ ] Procfile для production (web + worker для Solid Queue)
- [ ] Запуск миграций при деплое (release phase)

## Надёжность
- [ ] Retry-логика в джобах при недоступности MOEX API (встроенный retry в ActiveJob или rescue с логированием)
- [ ] Кэширование ответов CSV эндпоинтов (Solid Cache, инвалидация после каждого успешного обновления)

## Будущие фазы
- Dividend (дивиденды) — парсинг Dohod.ru
