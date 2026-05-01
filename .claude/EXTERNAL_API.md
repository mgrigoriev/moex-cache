# External API Documentation

Два источника данных:

- **MOEX ISS API** — основной, всё кроме прогноза дивидендов.
- **dohod.ru** — HTML-скрейпинг прогноза дивидендов на 1 акцию на ближайшие 12 месяцев.

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

---

### Курсы валют (CETS)

**URL:**
```
https://iss.moex.com/iss/engines/currency/markets/selt/boards/CETS/securities.csv?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,LAST,MARKETPRICE&securities=USD000UTSTOM,EUR_RUB__TOM,CNYRUB_TOM,AMDRUB_TOM
```

**Описание:** Курсы валют T+1 (`_TOM`-контракты) на валютном рынке MOEX. Запрос фильтрует только нужные тикеры.

**Тикеры:**
| Валюта | SECID |
|--------|-------|
| USD | `USD000UTSTOM` |
| EUR | `EUR_RUB__TOM` |
| CNY | `CNYRUB_TOM` |
| AMD | `AMDRUB_TOM` |

**Логика выбора цены:** `LAST` → если пусто, `MARKETPRICE`. Запись пропускается только если оба поля пустые.

Причина: ни одно поле не заполнено для всех 4 валют. EUR давно не торгуется активно (есть только `MARKETPRICE`), AMD недостаточно ликвиден для расчёта `MARKETPRICE` (есть только `LAST`).

---

### Состав индексов MOEX (analytics)

**URL (IMOEX):**
```
https://iss.moex.com/iss/statistics/engines/stock/markets/index/analytics/IMOEX.csv?iss.meta=off&iss.only=analytics&analytics.columns=ticker,weight&limit=100
```

**URL (MOEXBC):**
```
https://iss.moex.com/iss/statistics/engines/stock/markets/index/analytics/MOEXBC.csv?iss.meta=off&iss.only=analytics&analytics.columns=ticker,weight&limit=100
```

**Описание:** Состав индекса с весами. `IMOEX` — основной индекс MOEX (~50 бумаг), `MOEXBC` — Blue Chips (15 бумаг). Полный набор колонок в API: `indexid;tradedate;ticker;shortnames;secids;weight;tradingsession;trade_session_date`. Через `analytics.columns` сокращаем до двух нужных. **Важно:** ISS по умолчанию режет ответ на 20 строк, нужен `limit=100` чтобы получить весь состав.

**Формат ответа:** CSV, разделитель `;`. С `iss.meta=off` всё равно остаётся секционный заголовок `analytics` и строка с именами колонок (`ticker;weight`) — фильтруются по `ticker == "ticker"` или `blank?`.

**Пример ответа (IMOEX):**
```
ticker;weight
LKOH;16.52
GAZP;9.56
SBER;15.9
```

**Поля:**
| Поле | Описание |
|------|----------|
| `ticker` | Тикер инструмента |
| `weight` | Вес в индексе, % (MOEX отдаёт `16.52`; в БД храним долю — делим на 100, получаем `0.1652`) |

**Стратегия обновления:** full refresh (`delete_all + insert_all` в транзакции). Состав ребалансируется ~раз в квартал; при ребалансировке тикеры выбывают, поэтому upsert не подходит. Если ответ пуст — пропускаем (защита от обнуления при сбое).

---

## dohod.ru — прогноз дивидендов

**URL-шаблон:**
```
https://www.dohod.ru/ik/analytics/dividend/<ticker>
```

Тикер в URL в нижнем регистре: `sber`, `gazp`, `sberp`, `mtss` и т.д.

**Описание:** Публичная HTML-страница с аналитикой по дивидендам. Нас интересует только одна строка — прогноз на ближайшие 12 месяцев.

**Целевой блок HTML:**
```html
<tr class="forecast">
  <td class="black">след 12m. (прогноз)</td>
  <td class="black11">35</td>
  <td class="black11"> - </td>
</tr>
```

Значение — во второй ячейке (`tr.forecast td:nth-child(2)`), парсится через Nokogiri.

**Правила обработки:**
| Случай | Действие |
|--------|----------|
| Число (`35`, `12.5`, `0`) | Записываем `BigDecimal(value)` |
| Прочерк `-` | Записываем `NULL` |
| Пустая ячейка | Записываем `NULL` |
| Нет блока `tr.forecast` | Записываем `NULL` |
| 404 / 5xx / network error | `raise` в клиенте, сервис ловит, логирует warn, пропускает тикер |

`NULL` пишется явно, перетирая прежнее значение — оно скорее всего устарело. При сетевом сбое прежнее значение сохраняется до следующего успешного обновления.

**Стратегия обновления:** ежесуточно, по одному запросу на тикер из таблицы `stocks`, пауза 1с между запросами (~50 секунд на полный цикл). Партиальные сбои допустимы и логируются — `Rails.logger.warn("UpdateDividendForecasts: <secid> skipped (...)")`.
