# План разработки MOEX Cache Service

Сервис в проде: `https://moex-cache-ff34f14a1c26.herokuapp.com`. Все основные фазы закрыты, дальше — точечные улучшения по запросу.

## Фаза 1: Модели ✅
- [x] Stock + Fund (secid, market_price)
- [x] Ofz + CorporateBond (secid, short_name, market_price, ytm, duration, coupon_percent, coupon_period, maturity_date, face_value, accrued_interest)
- [x] Currency (secid, market_price) — фиксированный список тикеров: USD, EUR, CNY, AMD
- [x] ImoexComponent + MoexbcComponent (ticker, weight как доля 0..1)

## Фаза 2: Интеграция с MOEX API ✅
- [x] MoexClient в `app/lib` — `fetch(url)`, `parse(lines)`, `fetch_bonds(...)`, `parse_index(...)`
- [x] `fetch_stocks` (TQBR), `fetch_funds` (TQTF)
- [x] `fetch_ofz` (TQOB), `fetch_corporate_bonds` (TQCB)
- [x] `fetch_currencies` (CETS, фолбэк LAST → MARKETPRICE, нормализация по lot)
- [x] `fetch_imoex`, `fetch_moexbc` (statistics analytics, `limit=100`)
- [x] Кодировка ответа: Windows-1251 → UTF-8
- [x] Пропуск строк с пустым MARKETPRICE

## Фаза 3: Фоновые задачи ✅
- [x] Solid Queue на одной БД (web + worker локально через `bin/dev`/foreman)
- [x] Jobs: Stocks, Funds, Ofz, CorporateBonds, Currencies, Imoex, Moexbc, DividendForecasts
- [x] Services: тонкие обёртки над клиентом + upsert / full refresh
- [x] Локальное расписание в `config/recurring.yml` (production использует Heroku Scheduler)
- [x] Summary-логи во всех `Update*`-сервисах для видимости в Heroku-логах

## Фаза 4: API эндпоинты ✅
- [x] `GET /stocks.csv` — secid, market_price, dividend_forecast (только для in_portfolio акций)
- [x] `GET /funds.csv`
- [x] `GET /ofz.csv`
- [x] `GET /corporate_bonds.csv`
- [x] `GET /currencies.csv`
- [x] `GET /imoex.csv` — состав индекса MOEX, ticker + weight (как доля)
- [x] `GET /moexbc.csv` — состав индекса MOEX Blue Chips
- [x] CSV сериализаторы в `app/serializers/csv/` под неймспейсом `Csv`
- [x] `Csv::BaseSerializer` — общая логика через `HEADERS.map { |f| record.public_send(f) }`

## Фаза 5: Тесты ✅
- [x] RSpec + shoulda-matchers + WebMock + factory_bot_rails
- [x] Фабрики, спеки моделей, сервисов, джобов, клиентов, сериализаторов (~95 примеров)
- [x] Rubocop (rubocop-rails-omakase) — без нарушений
- [x] CI: GitHub Actions (rspec + rubocop + brakeman + bundler-audit)

## Фаза 6: Авторизация API ✅
- [x] API-ключ через GET-параметр `?api_key=...`
- [x] Хранение в env-переменной `API_KEY` (dotenv-rails локально, Heroku config vars в prod)
- [x] `before_action` в `ApplicationController` с `secure_compare`, 401 при невалидном/отсутствующем ключе

## Фаза 7: Деплой на Heroku ✅
- [x] App: `moex-cache` (region EU), Eco dyno ($5/мес)
- [x] Postgres `essential-0` ($5/мес)
- [x] Heroku Scheduler (бесплатный)
- [x] GitHub Integration → Automatic Deploys из `main`
- [x] `Procfile`: `release: bin/rails db:migrate`, `web: bundle exec puma -C config/puma.rb`
- [x] Env vars: `API_KEY`, `DATABASE_URL`, `SECRET_KEY_BASE`

### Heroku Scheduler — actual schedule
| Время | Команда |
|-------|---------|
| hourly `:00` | `UpdateStocksJob.perform_now` |
| hourly `:10` | `UpdateFundsJob.perform_now` |
| hourly `:20` | `UpdateOfzJob.perform_now` |
| hourly `:30` | `UpdateCorporateBondsJob.perform_now` |
| hourly `:40` | `UpdateCurrenciesJob.perform_now` |
| daily 06:00 UTC | `UpdateImoexJob.perform_now; UpdateMoexbcJob.perform_now` |
| daily 06:30 UTC | `UpdateDividendForecastsJob.perform_now` |

Котировки — hourly со смещением 10 мин (best-effort scheduler, hourly = self-healing). Составы индексов и прогноз дивидендов — daily, потому что меняются редко и dohod.ru делает ~15 HTTP-запросов с паузой 1с.

## Фаза 8: Дивиденды ✅
- [x] HTML-скрейпинг dohod.ru (`DohodClient`, Nokogiri)
- [x] Поле `Stock#dividend_forecast` (decimal, nullable)
- [x] Флаг `Stock#in_portfolio` + scope `Stock.in_portfolio`
- [x] Сид-миграция начального портфеля (19 тикеров)
- [x] `UpdateDividendForecasts` с per-ticker rescue, прогресс-логами `[N/total]`, паузой 1с
- [x] Расширение `/stocks.csv` третьей колонкой
- [x] Документация в `docs/operations.md`: управление портфелем через консоль (а не миграции)

## Бэклог (по запросу)

Не сделано, не блокирует. Открыть только если появится боль.

- **Retry-логика в джобах при недоступности MOEX.** Сейчас если MOEX отдаёт 503, batch-джобы (`UpdateStocks`/`UpdateFunds`/`UpdateOfz`/`UpdateCorporateBonds`/`UpdateCurrencies`) падают целиком. У `UpdateImoex`/`UpdateMoexbc` есть guard от пустого ответа, у дивидендов — per-ticker rescue. Hourly расписание уже даёт самовосстановление — реальной боли нет. Можно добавить `retry_on Net::OpenTimeout, wait: :exponentially_longer` в `ApplicationJob` если станет шумно в логах.
- **Кэширование CSV-ответов через Solid Cache.** Сейчас каждый `/stocks.csv` запрашивает все 250+ строк и сериализует в CSV. Под текущей нагрузкой (Sheets раз в 30 мин) это копейки. Имеет смысл если появится больше внешних потребителей или несколько таблиц.
- **Дополнительные источники данных.** Например — фактические дивидендные выплаты (история), календарь корпоративных событий, новости. По мере необходимости.
