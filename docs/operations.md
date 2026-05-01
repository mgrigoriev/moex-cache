# Operations

## Деплой

GitHub Integration включён, push в `main` автоматически деплоит:

```bash
git push origin main
```

Если нужно посмотреть статус билда:
```bash
heroku releases          # история релизов
heroku releases:info v42 # детали релиза
```

Откатиться на предыдущий релиз:
```bash
heroku rollback          # на предыдущий
heroku rollback v40      # на конкретный
```

## Логи

```bash
heroku logs --tail              # стрим всего
heroku logs --tail --dyno web   # только web dyno
heroku logs --tail --source app # без шума от роутера
heroku logs -n 1000             # последние 1000 строк
```

При падении джоба в Scheduler:
```bash
heroku logs --tail --source scheduler
```

Или фильтр по имени dyno (one-off scheduler job выглядит как `scheduler.1234`):
```bash
heroku logs --dyno scheduler.5512
```

## Запустить джоб вручную

```bash
heroku run "bin/rails runner 'UpdateStocksJob.perform_now'"
```

Полезно сразу после первого деплоя или когда Scheduler пропустил тик.

## Heroku Console

```bash
heroku run rails console
```

Внутри — обычная Rails-консоль с доступом к production БД. **Осторожно с записью.**

Полезные проверки:
```ruby
Stock.count
Stock.order(updated_at: :desc).first.updated_at  # когда последний раз обновлялось
Currency.all.map { |c| [c.code, c.market_price] }
```

## Управление портфелем

`UpdateDividendForecastsJob` обновляет `dividend_forecast` только для акций с `in_portfolio: true`. Начальный состав засеян миграцией `20260501150000_set_initial_portfolio_stocks.rb` (19 тикеров).

**Дальнейшие изменения портфеля — только через консоль, не через новые миграции.** Миграции — для схемы и одноразовых backfill'ов; рутинная правка портфеля через них захламит историю.

```ruby
Stock.in_portfolio.pluck(:secid)                          # текущий состав
Stock.find_by(secid: "SBER").update!(in_portfolio: true)  # добавить в портфель
Stock.find_by(secid: "SBER").update!(in_portfolio: false) # убрать
Stock.where(secid: %w[SBER GAZP LKOH]).update_all(in_portfolio: true)  # пакетно
```

После добавления нового тикера — дёрнуть джоб, чтобы заполнить прогноз сразу:
```bash
heroku run "bin/rails runner 'UpdateDividendForecastsJob.perform_now'"
```

## Env vars

```bash
heroku config                          # все переменные
heroku config:get API_KEY              # конкретная
heroku config:set API_KEY=новый_ключ   # установить (рестартует dyno автоматически)
heroku config:unset NAME               # удалить
```

После смены `API_KEY` обновить во всех местах где используется (Google Sheets таблицы).

## Scheduler

```bash
heroku addons:open scheduler  # откроет UI в браузере
```

Изменить время / частоту / команду — карандаш справа. Удалить — крестик.

## Restart

```bash
heroku ps:restart      # все dyno
heroku ps:restart web  # только web
```

Обычно не нужно — Heroku сам рестартит при `config:set` и при деплое.

## База данных

```bash
heroku pg:info       # размер, версия, лимиты
heroku pg:psql       # интерактивный psql
heroku pg:credentials:url DATABASE  # connection URL
```

Бэкап на лету:
```bash
heroku pg:backups:capture
heroku pg:backups:download   # скачивает latest.dump в текущую директорию
```

Restore из дампа в локальную БД:
```bash
pg_restore --verbose --clean --no-acl --no-owner -d moex_cache_development latest.dump
```

## CI

Конфиг: `.github/workflows/ci.yml`.

Что прогоняется на push/PR:
- `scan_ruby`: brakeman, bundler-audit
- `lint`: rubocop
- `test`: rspec (с PostgreSQL 16 как service)

Локальный аналог:
```bash
bin/ci
```

## Тестирование production

```bash
# 401 без ключа
curl -i 'https://moex-cache-ff34f14a1c26.herokuapp.com/stocks.csv'

# 200 с ключом
curl 'https://moex-cache-ff34f14a1c26.herokuapp.com/stocks.csv?api_key=KEY' | head

# health check (без авторизации)
curl 'https://moex-cache-ff34f14a1c26.herokuapp.com/up'
```

## Стоимость и квоты

```bash
heroku ps              # сколько dyno активно сейчас
```

Текущий месяц: посмотреть в [Heroku Dashboard → Billing](https://dashboard.heroku.com/account/billing).

Лимит — 1000 dyno-часов на Eco. При его исчерпании dyno остановятся до начала следующего месяца. Расчёт у нас укладывается в ~200-300 ч/мес.

## Если что-то сломалось

1. **`heroku ps`** — все ли dyno crashed?
2. **`heroku logs --tail`** — ищи бэктрейс
3. **`heroku releases`** — что было в последнем деплое?
4. **`heroku rollback`** — если прод сломался деплоем
5. **`heroku run rails console`** — посмотреть состояние БД
