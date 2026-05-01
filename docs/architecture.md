# Architecture

## Поток данных

```
┌──────────┐         ┌──────────────┐         ┌──────────┐
│   MOEX   │ ──CSV──▶│  MoexClient  │ ──hash──▶│  Service │ ──upsert──▶ DB
│ ISS API  │         │  (app/lib)   │         │  (app/   │
└──────────┘         └──────────────┘         │ services)│
                                               └──────────┘
                                                              ┌──────────┐
                                  ┌─────CSV────────────┐ ────▶│  Google  │
GET /xxx.csv ──▶ Controller ──▶ Csv::Serializer ◀── DB │      │  Sheets  │
                                                       └──────└──────────┘
```

Запуск каждые сутки в 08:00 UTC через **Heroku Scheduler**:
```
heroku run bin/rails runner 'UpdateXxxJob.perform_now'
```

## Слои

### `app/lib/moex_client.rb`
Один HTTP-клиент для всех MOEX-эндпоинтов.

- `fetch(url)` — приватный, делает GET, форсит `Windows-1251 → UTF-8` (MOEX отдаёт `iso-8859-1` в заголовке, но фактически кириллица в `Windows-1251`).
- `parse(lines)` — приватный, для simple-форматов (stocks/funds): `secid;price`.
- `fetch_bonds(marketdata_url, securities_url)` — приватный, делает 2 запроса и мерджит по SECID.
- `parse_index(lines)` — приватный, для составов индексов: `ticker;weight`.
- Публичные методы: `fetch_stocks`, `fetch_funds`, `fetch_ofz`, `fetch_corporate_bonds`, `fetch_currencies`, `fetch_imoex`, `fetch_moexbc`.

URL'ы и точные параметры запросов — в `.claude/EXTERNAL_API.md`.

### `app/services/update_*.rb`
Каждый сервис тонкий:
1. Дёргает соответствующий метод клиента
2. Делает `Model.upsert_all(records, unique_by: :secid, update_only: [...])`

`update_only` важен — НЕ обновляет `created_at`, обновляет только реально изменяемые поля.

### `app/jobs/update_*_job.rb`
Однострочные обёртки над сервисами для запуска через ActiveJob (`perform_now` или `perform_later`).

### `app/serializers/csv/`
Под неймспейсом `Csv`:
- `Csv::BaseSerializer` — общая логика. CSV строится через `HEADERS.map { |f| record.public_send(f) }`.
- Конкретные сериализаторы только определяют `HEADERS` (массив имён полей/методов).

### `app/controllers/`
Простые контроллеры — каждый делает `render plain: Csv::XxxSerializer.call(Model.order(:secid)), content_type: "text/csv"`.

`ApplicationController` имеет `before_action :authenticate!` — все наследники защищены автоматически.

### `app/models/`
Минимум: валидации (`presence`, `uniqueness`). Никакой логики получения/трансформации данных в моделях не лежит.

## Как добавить новую модель

Например, дивиденды.

1. **Модель + миграция:**
   ```bash
   bin/rails generate model Dividend secid:string ...
   ```
   В миграции: `null: false` где надо, `add_index :dividends, :secid, unique: true`.

2. **Фабрика:** `spec/factories/dividends.rb`

3. **Клиент:** добавить метод `fetch_dividends` в `MoexClient` (или новый клиент если источник другой).

4. **Сервис:** `app/services/update_dividends.rb` с `upsert_all`.

5. **Джоб:** `bin/rails generate job UpdateDividends`. Реализация — однострочник.

6. **Сериализатор:** `app/serializers/csv/dividend_serializer.rb`, наследник `Csv::BaseSerializer`, только `HEADERS`.

7. **Контроллер + роут:**
   ```ruby
   # config/routes.rb
   get "dividends.csv", to: "dividends#index"
   ```
   ```ruby
   # app/controllers/dividends_controller.rb
   class DividendsController < ApplicationController
     def index
       render plain: Csv::DividendSerializer.call(Dividend.order(:secid)), content_type: "text/csv"
     end
   end
   ```

8. **Спеки:** model, service, job, serializer (по образцу существующих).

9. **Heroku Scheduler:** добавить cron-задачу для джоба.

10. **Документация:** обновить `docs/api.md` и `.claude/EXTERNAL_API.md`.

## Технические решения

- **Solid Queue + Solid Cache на той же БД** (без отдельной queue/cache БД). На Heroku в production воркер не запускается — Solid Queue работает только локально для recurring schedule. На production джобы триггерятся напрямую через `heroku run`/Scheduler.
- **`upsert_all` вместо find_or_create** — bulk-операция в одном SQL-запросе.
- **`update_only` в upsert** — избегаем обновления `created_at` и других полей которые не должны меняться. Также фиксит баг с дублированием `updated_at` в SQL.
- **BigDecimal для цен** — финансовые данные требуют точной десятичной арифметики, Float дал бы ошибки представления.
- **Custom `table_name = "ofz"` для модели Ofz** — Rails плюрализовал бы в "ofzs", выглядит криво.
- **Full refresh вместо upsert для составов индексов** (`UpdateImoex`, `UpdateMoexbc`): состав индекса меняется редко, но при ребалансировке тикеры выбывают — `delete_all + insert_all` в транзакции проще, чем upsert + догоняющая чистка. Если MOEX вернул пустой список, ничего не делаем (защита от обнуления при сбое внешнего API).
