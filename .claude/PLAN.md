# План разработки MOEX Cache Service

## Фаза 1: Модели ✅
- [x] Stock + Fund (secid, market_price)
- [x] Ofz + CorporateBond (secid, short_name, market_price, ytm, duration, coupon_percent, coupon_period, maturity_date, face_value, accrued_interest)

## Фаза 2: Интеграция с MOEX API ✅
- [x] MoexClient в app/lib — fetch(url), parse(lines), fetch_bonds(marketdata_url, securities_url)
- [x] fetch_stocks (TQBR), fetch_funds (TQTF)
- [x] fetch_ofz (TQOB), fetch_corporate_bonds (TQCB)
- [x] Кодировка ответа: Windows-1251 → UTF-8
- [x] Пропуск строк с пустым MARKETPRICE

## Фаза 3: Фоновые задачи ✅
- [x] Solid Queue на одной БД
- [x] Jobs: UpdateStocksJob, UpdateFundsJob, UpdateOfzJob, UpdateCorporateBondsJob
- [x] Services: UpdateStocks, UpdateFunds, UpdateOfz, UpdateCorporateBonds
- [x] Расписание every 4h: stocks@0m, funds@3m, ofz@6m, corporate_bonds@9m
- [x] bin/dev запускает web + worker через foreman + Procfile.dev

## Фаза 4: API эндпоинты ✅
- [x] GET /stocks.csv
- [x] GET /funds.csv
- [x] GET /ofz.csv
- [x] GET /corporate_bonds.csv
- [x] CSV сериализаторы в app/serializers/

## Фаза 5: Тесты ✅
- [x] RSpec + shoulda-matchers + WebMock
- [x] Спеки моделей, сервисов, джобов, клиента (30 примеров)

## Фаза 6: Интеграция с Google Sheets
- [ ] Тестирование CSV эндпоинтов с Google Sheets
- [ ] Настройка CORS если необходимо

## Фаза 7: Деплой
- [ ] Настройка production окружения
- [ ] Деплой через Kamal

## Будущие фазы
- Currency (валюты) — интеграция с Google Finance
- Dividend (дивиденды) — парсинг Dohod.ru
