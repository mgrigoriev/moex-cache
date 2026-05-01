# API

Все эндпоинты возвращают `text/csv` и требуют авторизации.

**Base URL:** `https://moex-cache-ff34f14a1c26.herokuapp.com`

## Авторизация

API-ключ передаётся в query-параметре `api_key`:

```
GET /stocks.csv?api_key=<ваш-ключ>
```

Без ключа или с неверным — `401 Unauthorized`. Сравнение через `ActiveSupport::SecurityUtils.secure_compare` (защита от timing-атак).

Ключ хранится в env-переменной `API_KEY`:
- **Локально:** в `.env` (`dotenv-rails`)
- **Production:** Heroku config var (`heroku config:set API_KEY=...`)

Ротация ключа: `heroku config:set API_KEY=$(openssl rand -hex 32)` + обновить во всех таблицах Google Sheets, которые его используют.

## Эндпоинты

### `GET /stocks.csv`
Акции с основного режима торгов MOEX (борд **TQBR**).

```csv
secid,market_price,dividend_forecast
GAZP,124.24,
SBER,326.03,35
MTSS,210.50,28.5
YDEX,4290,
```

`dividend_forecast` — прогноз дивидендов на 1 акцию (₽) на ближайшие 12 месяцев. Источник — `dohod.ru`, обновляется раз в сутки. Пустая ячейка означает: на странице не было блока прогноза, либо там стоял прочерк / пустое значение, либо страница не открылась с прошлого успешного обновления (в последнем случае значение остаётся прежним до следующей попытки).

**Важно:** `dividend_forecast` заполняется только для акций, помеченных как портфельные (`stocks.in_portfolio = true`). Для остальных бумаг колонка всегда пустая. Управление портфелем — через Rails-консоль:

```ruby
Stock.find_by(secid: "SBER").update!(in_portfolio: true)
Stock.in_portfolio.pluck(:secid)  # текущий состав
```

### `GET /funds.csv`
ETF и БПИФы (борд **TQTF**).

```csv
secid,market_price
TMOS,6.15
SBMX,18.42
```

### `GET /ofz.csv`
Облигации федерального займа (борд **TQOB**).

```csv
secid,market_price,ytm,duration,secid,short_name,coupon_percent,coupon_period,maturity_date,face_value,accrued_interest
SU26207RMFS9,96.75,13.08,274,SU26207RMFS9,ОФЗ 26207,8.15,182,2027-02-03,1000,18.53
```

`secid` дублируется специально — нужно для совместимости с моей таблицей в Google Sheets.

### `GET /corporate_bonds.csv`
Корпоративные облигации (борд **TQCB**). Структура идентична `/ofz.csv`.

### `GET /currencies.csv`
Курсы валют T+1 на валютном рынке MOEX (борд **CETS**). Возвращает короткие коды вместо MOEX-тикеров.

```csv
code,market_price
AMD,20.5975
CNY,10.9775
EUR,87.7771
USD,74.9775
```

Маппинг тикеров определён в `Currency::TICKERS`:

| MOEX SECID | Code | Lot |
|------------|------|-----|
| `USD000UTSTOM` | USD | 1 |
| `EUR_RUB__TOM` | EUR | 1 |
| `CNYRUB_TOM` | CNY | 1 |
| `AMDRUB_TOM` | AMD | 100 |

`lot` — размер лота на MOEX. Для AMD котировка идёт за 100 драм, при сохранении делим на 100, чтобы в БД был курс за 1 единицу.

### `GET /imoex.csv`
Состав индекса MOEX (`IMOEX`) — тикер и вес как доля (0..1). Отсортирован по убыванию веса.

```csv
ticker,weight
LKOH,0.1652
GAZP,0.0956
SBER,0.159
```

MOEX отдаёт `weight` в процентах (`16.52` = 16.52%); при сохранении делим на 100, чтобы в БД хранилась доля. Источник: `https://iss.moex.com/iss/statistics/engines/stock/markets/index/analytics/IMOEX.csv`. Состав ребалансируется ~раз в квартал; обновляем ежечасно для единообразия с остальными эндпоинтами.

### `GET /moexbc.csv`
Состав индекса MOEX Blue Chips (`MOEXBC`) — 15 крупнейших голубых фишек. Структура идентична `/imoex.csv`.

```csv
ticker,weight
LKOH,0.1649
SBER,0.159
T,0.0611
```

## Использование в Google Sheets

```
=IMPORTDATA("https://moex-cache-ff34f14a1c26.herokuapp.com/stocks.csv?api_key=ВАШ_КЛЮЧ")
```

Google Sheets кеширует ответ ~30 мин — это норма для нашего сценария (данные обновляются раз в сутки).

## Health check

```
GET /up
```

Без авторизации — это Rails-овый `Rails::HealthController`, который не проходит через `ApplicationController`.
