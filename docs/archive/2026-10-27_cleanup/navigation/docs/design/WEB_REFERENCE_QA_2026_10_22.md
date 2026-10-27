> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/WEB_REFERENCE_QA_2026_10_22.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/WEB_REFERENCE_QA_2026_10_22.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `2b4fa65d8256c9b64d3e3c88850bf2f891d0d0921ed8914fda87c62ab6a10483`.

# Culmina: обмежений фікс і розширений QA — 2026-10-22

База: локальний `develop`, `a594837`. Власник дозволив виправити знайдений
конфлікт типографіки Plan і розширити аналіз на теми/стани, файли,
геолокацію, Flutter/Android та продуктивність. Це не перенесення нового
вебдизайну у Flutter і не приймання Android-релізу.

## Зміна

У `design/home-lab/hybrid-refinement.css` уточнено специфічність чотирьох
правил Plan. П'ять підписів Site and night / Target / Rig / Night & Moon /
Weather тепер мають погоджені 16 px / 600, значення — 15 px / 400.
Додано браузерну регресію до `scripts/check_hybrid_refinement.cjs`:
375/412 px × light/dark/field при 100%; усі шість комбінацій PASS.
Наявні чужі зміни Flutter та їхніх тестів залишено недоторканими.

## Вебперевірка

- 79 комбінацій основного екрана/сценарію і 31 стан редакторів,
  списків, disclosures, фільтрів та валідації × 3 теми × 2 ширини =
  **660 комбінацій** при 100%. Зафіксована ширина саме телефону,
  а не всієї студії. 1717 знімків у фінальному маніфесті.
- Контейнерні перевірки: 660/660 PASS. Це перевірка горизонтального
  переповнення, не автоматична оцінка композиції або контрасту.
- Окремо візуально переглянуто виправлений Plan у трьох темах,
  крайні стани Night/Moon/Weather, редактори, помилки валідації,
  review/результат backup та review геолокації/метаданих.
- 48/48 файлових і геолокаційних сценаріїв PASS: реальний локальний
  JSON review/cancel/apply/save, відмова невалідному JSON, browser
  geolocation із контрольованими координатами, simulated denied /
  unavailable / timeout, export/review/cancel, повний preview backup,
  stale guard, точне відновлення записів і збереження стороннього ключа.
- Наявні тести: 64/64 model checks і 11/11 browser contract scenarios PASS.
- Початковий широкий прогін мав один `Failed to fetch`, одне очікування
  редактора та один передчасний знімок незавантаженого Weather. Окремий
  повтор цих станів із очікуванням контенту пройшов без page errors і
  failed requests. Початкові записи збережено; причину мережевого збою
  не встановлено, продуктового дефекту не підтверджено.
- Ізольовані браузерні контексти; стан браузера власника не читався.

## Нове зауваження вебдизайну

**P3 — нейтральні browser-native radio glyphs у field-темі.**
Plan → Rig, field, 100%, 375/412 px: radio input має
`accent-color: rgb(255, 0, 0)`, `color-scheme: dark`, `appearance: auto`,
але Chromium залишає білі/сірі частини контролів. Це не відповідає
суто червоно-чорній палітрі. Функція працює; це окрема задача вигляду
браузерного еталона, а не доказ аналогічного дефекту Flutter.
Рекомендація: окремо погодити/перевірити red-only оформлення цих glyphs.
У цьому обмеженому пакеті не виправлялося.

## Flutter / Android

- `flutter analyze --no-pub`: PASS, no issues found.
- 107/107 цільових host-тестів PASS: backup/restore, metadata channel
  stand-in, location picker/VM, поточні редактори rig/target.
- Додатково 21/21 host-тестів stored Undo, deletion state та manifest codec
  PASS; разом 128 цільових host-тестів. Це не повний Flutter test suite.
- Реальний Android emulator, окремий read-only запуск AVD із тимчасовим
  станом; фізичний телефон не використовувався.
- Оригінальний `hybrid_migration_smoke_test.dart`: **FAILED** після
  9:19 на рядку 653: після Undo не знайдено `Deletion undone`.
  Збережено 74 знімки, зокрема всі вісім основних екранів у трьох
  темах при 100%/200%. 200% виконано як частину наявного harness,
  а не як новий критерій вебприймання. Початкова геометрія пристрою:
  1080×2340 px, density 320, тобто 540×1170 logical px.
- Нативний вигляд ще відстає від нового вебкандидата: попередня ієрархія
  Home/Plan, попередній колір/дужка шкали ночі та Return to now/start
  замість двох нових jump-кнопок. Це не усувалося цим CSS-фіксом.
- Початковий smoke не дійшов до фінальних native file/backup assertions.
  Окремий тимчасовий діагностичний harness у `build/qa-expanded-20261022/`
  завершився PASS за 4:00 на 412 logical px. У ньому пропущено вже зняту
  baseline matrix, залишено три знімки та додано обмежене очікування
  повідомлення після двох асинхронних Undo. Оригінальний тест не змінено.
- Діагностика підтвердила точний portable manifest після Undo (IDs, blocks,
  events, result), відновлення активного site з ID/координатами/зоною,
  synthetic FITS через Android file I/O і production reader, а також
  production backup/check/stage/apply/reopen SQLite; archive 25846 bytes,
  schema 27. Це controlled fixture evidence, не дані власника.
- Результат сумісний із недостатнім очікуванням async Undo в початковому
  smoke. Оскільки ширина також відрізнялася, єдиною доведеною причиною
  збою timing не оголошується. Початковий FAILED залишається відкритим
  validation finding; production-дефект втрати даних не підтверджено.

## Продуктивність

Локальний Chromium, loopback, без throttling: 5 відкриттів кожного з восьми
екранів дали медіани ready-time 107–185 ms. Для 30 змін кількості кадрів
у block editor input → другий requestAnimationFrame: p50 6.1 ms,
p95 9.7 ms, max 15.7 ms. Ready-time включає automation round trip і
очікування шрифтів; це smoke-вимірювання конкретного комп'ютера.
Воно не доводить Android/release продуктивність.

Наявний `perf_scenarios_test.dart` виконано в Android **profile** mode:
16 сценаріїв завершено, PASS; пристрій налаштовано на 824×1830 px при
density 320, тобто 412×915 logical px. Це один прогін на емуляторі WHPX,
без встановленого критерію швидкодії та без порівняння до/після.

| Сценарій | Кадрів | Build p90 / max, ms | Raster p90 / max, ms |
| --- | ---: | ---: | ---: |
| Rig open | 11 | 31.57 / 225.42 | 18.91 / 73.68 |
| Rig type name | 37 | 4.83 / 23.68 | 16.19 / 31.82 |
| Plan open | 18 | 0.63 / 329.53 | 9.44 / 71.24 |
| Block edit | 10 | 6.51 / 7.30 | 5.73 / 8.41 |
| Night/Moon detail | 10 | 1.22 / 13.75 | 103.79 / 237.73 |

Каталог: 439 ms; list 300 збережених прикладів: 56 ms; кандидати: 364 ms.
Створення 300 тестових записів: 9420 ms — це підготовка benchmark fixture,
а не доведений час старту звичайного застосунку.
Підтверджені локальні сплески: перші відкриття Rig/Plan і raster Night/Moon.
Для оптимізації потрібен окремий trace цих трьох шляхів із розділенням
першого/повторного відкриття. Дані емулятора не доводять аналогічну проблему
на фізичному пристрої. Метод profile-mode узгоджений із
[документацією Flutter](https://docs.flutter.dev/tools/devtools/performance).

## Докази та межі

Тимчасовий evidence bundle поза Git:
`C:/Users/zalub/.codex/visualizations/2026/10/21/01a160b5-4e44-7191-90f9-be213b3d40a3/qa-expanded-20261022/`.
Основні файли: `gallery.html`, `matrix-results.json`,
`matrix-rechecks.json`, `services-results.json`, `browser-performance.json`,
`native-drive.log`, `native/`, `flutter-analyze.log`, `flutter-targeted.log`.
Профіль: `native-performance.log`, `native-performance.json`,
`native-performance-summary.json`.
Діагностика: `native-diagnostic.log`, `native-diagnostic/integration-report.json`,
`undo-tests.log`; окремий diagnostic PASS не замінює початковий smoke.
Композиція всіх 1717 знімків не оцінювалася вручну; автоматична матриця
і вибірковий візуальний перегляд позначені окремо.
Реальний GPS, OS file-provider/share UI, реальні camera files, process-restart
і фізичні Android performance-вимірювання не підтверджені цим запуском.

## Висновок і наступний крок

Погоджений обмежений фікс завершено. Вебкандидат **готовий до приймання
з неблокувальним зауваженням P3 щодо browser-native field controls**.
Виправлення має browser regression і фактичні рендери.
Наступний крок вебпроцесу — приймання/фіксація конкретного еталона власником.

Нативний застосунок не отримує загального PASS: нові вебрішення ще не
перенесені, початковий smoke має відтворений validation failure. Перед
нативним прийманням потрібне окреме усунення/перевірка очікування Undo
без послаблення перевірки відновлених даних. Для performance-етапу
виділено три конкретні шляхи: Rig open, Plan open, Night/Moon raster.
У цьому запуску не змінювалися Flutter, roadmap, залежності або CI;
коміт/публікація та новий етап міграції не виконувалися.
