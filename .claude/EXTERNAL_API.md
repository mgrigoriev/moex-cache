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
