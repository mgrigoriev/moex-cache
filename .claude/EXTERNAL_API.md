# External API Documentation

## MOEX ISS API

### Котировки акций (TQBR)

**URL:**
```
https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.csv?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE
```

**Описание:** Текущие рыночные цены всех акций основного режима торгов Московской биржи (борд TQBR). Возвращает тикер и последнюю цену. Цена может быть пустой, если торги по инструменту не проводились.

**Формат ответа:** CSV, разделитель `;`, без заголовка (благодаря `iss.meta=off`)

**Пример ответа:**
```
GAZP;124.24
SBERP;326.03
YDEX;4290
MGNZ;
```

**Поля:**
| Поле | Описание |
|------|----------|
| `SECID` | Тикер инструмента |
| `MARKETPRICE` | Рыночная цена (пустая, если нет данных) |

---

### Котировки фондов (TQTF)

**URL:**
```
https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQTF/securities.csv?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE
```

**Описание:** Текущие рыночные цены ETF и БПИФов, торгующихся на Московской бирже (борд TQTF). Формат и правила обработки идентичны TQBR.

**Формат ответа:** CSV, разделитель `;`, без заголовка

**Поля:**
| Поле | Описание |
|------|----------|
| `SECID` | Тикер инструмента |
| `MARKETPRICE` | Рыночная цена (пустая, если нет данных) |

---

### ОФЗ (TQOB) — два запроса, объединяются по SECID

**Запрос 1 — рыночные данные:**
```
https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQOB/securities.csv?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE,YIELD,DURATION
```

Пример ответа:
```
SU26207RMFS9;96.75;13.08;274
SU26212RMFS9;91.451;13.17;593
```

**Запрос 2 — параметры бумаги:**
```
https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQOB/securities.csv?iss.meta=off&iss.only=securities&securities.columns=SECID,SHORTNAME,COUPONPERCENT,COUPONPERIOD,MATDATE,FACEVALUE,ACCRUEDINT
```

Пример ответа:
```
SU26207RMFS9;ОФЗ 26207;8.150;182;2027-02-03;1000;18.53
SU26212RMFS9;ОФЗ 26212;7.050;182;2028-01-19;1000;18.73
```

**Поля:**
| API поле | Колонка в БД | Описание |
|----------|-------------|----------|
| `SECID` | `secid` | Тикер |
| `MARKETPRICE` | `market_price` | Рыночная цена (% от номинала) |
| `YIELD` | `ytm` | Доходность к погашению, % |
| `DURATION` | `duration` | Дюрация, дней |
| `SHORTNAME` | `short_name` | Краткое название |
| `COUPONPERCENT` | `coupon_percent` | Купонная ставка, % |
| `COUPONPERIOD` | `coupon_period` | Период купона, дней |
| `MATDATE` | `maturity_date` | Дата погашения |
| `FACEVALUE` | `face_value` | Номинал |
| `ACCRUEDINT` | `accrued_interest` | НКД |

Записи без `MARKETPRICE` пропускаются.

---

### Корпоративные облигации (TQCB) — два запроса, объединяются по SECID

Идентичны ОФЗ по структуре и логике. Отличие только в URL (борд `TQCB` вместо `TQOB`):

**Запрос 1 — рыночные данные:**
```
https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQCB/securities.csv?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE,YIELD,DURATION
```

**Запрос 2 — параметры бумаги:**
```
https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQCB/securities.csv?iss.meta=off&iss.only=securities&securities.columns=SECID,SHORTNAME,COUPONPERCENT,COUPONPERIOD,MATDATE,FACEVALUE,ACCRUEDINT
```

Поля и правила обработки идентичны ОФЗ.
