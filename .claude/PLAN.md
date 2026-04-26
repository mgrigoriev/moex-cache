# План разработки MOEX Cache Service

## MVP: Акции (Stocks) и Фонды (Funds)

### Фаза 1: Модели ✅
- [x] Модель Stock + миграция (secid, market_price, NOT NULL, unique index)
- [x] Модель Fund + миграция (аналогично Stock)

### Фаза 2: Интеграция с MOEX API ✅
- [x] MoexClient в app/lib с общим приватным fetch(url) и parse(lines)
- [x] fetch_stocks — борд TQBR
- [x] fetch_funds — борд TQTF
- [x] Пропуск строк с пустым MARKETPRICE

### Фаза 3: Фоновые задачи ✅
- [x] Solid Queue настроен на одну БД (без отдельной queue БД)
- [x] UpdateStocksJob → UpdateStocks service → Stock.upsert_all
- [x] UpdateFundsJob → UpdateFunds service → Fund.upsert_all
- [x] Расписание: every 4 hours (development и production)
- [x] bin/dev запускает web + worker через foreman + Procfile.dev

### Фаза 4: API эндпоинты
- [ ] GET /stocks.csv
- [ ] GET /funds.csv

### Фаза 5: Интеграция с Google Sheets
- [ ] Тестирование CSV эндпоинтов с Google Sheets
- [ ] Настройка CORS если необходимо
- [ ] Документация API

### Фаза 6: Деплой и мониторинг
- [ ] Настройка production окружения
- [ ] Деплой через Kamal
- [ ] Мониторинг работы сервиса

## Будущие фазы (после завершения MVP)
- Bond (облигации) — по аналогии
- Currency (валюты) — интеграция с Google Finance
- Dividend (дивиденды) — парсинг Dohod.ru

## Дополнительные задачи
- [ ] Тесты
- [ ] Обработка edge cases
- [ ] Оптимизация производительности
