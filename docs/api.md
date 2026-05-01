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
secid,market_price
GAZP,124.24
SBERP,326.03
YDEX,4290
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

Маппинг секций определён в `Currency::CODE_BY_SECID`:

| MOEX SECID | Code |
|------------|------|
| `USD000UTSTOM` | USD |
| `EUR_RUB__TOM` | EUR |
| `CNYRUB_TOM` | CNY |
| `AMDRUB_TOM` | AMD |

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
