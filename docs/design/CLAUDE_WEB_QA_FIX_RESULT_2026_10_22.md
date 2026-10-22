# Виправлення WQA-01…WQA-06 вебеталона Hybrid — результат Claude, 22.10.2026

**Статус обмеженого пакета: COMPLETE.** Усі шість знахідок із [`INDEPENDENT_WEB_FINAL_QA_2026_10_22.md`](INDEPENDENT_WEB_FINAL_QA_2026_10_22.md) відтворено, мінімально виправлено та перевірено цільовими browser/regression доказами при 100%. Це результат одного доручення ([`CLAUDE_WEB_QA_FIX_GOAL_2026_10_22.md`](CLAUDE_WEB_QA_FIX_GOAL_2026_10_22.md)), **не** owner-приймання еталона, не загальна WCAG-відповідність Field і не готовність Android/Flutter.

## База, межі та збережена чужа робота

- Гілка `develop`, базовий коміт `5051bf3865ad62f2f2d48a45e20bd7247a7f9ada`.
- Змінено лише веб-прототип `design/home-lab/` (8 файлів, +53/−14 рядків), один новий скрипт перевірки, нові докази та цей звіт. Вихідний QA-звіт і його докази не змінювалися.
- Чужі dirty Flutter-файли (`lib/presentation/screens/equipment/equipment_editor.dart`, `lib/presentation/screens/target/target_selection_screen.dart`, два відповідні тести в `test/presentation/screens/`) і untracked `docs/design/migration/evidence/*` не редагувалися, не stage-илися й не комітилися.
- Не змінювалися: Flutter/native код, production theme, `tokens.json`, залежності, tooling pin, MCP/CLI, roadmap, CI. Нічого не встановлювалося; телефон, ADB, Flutter-тести та інші агенти не використовувалися; push не виконувався.
- Збережено заморожені рішення: лише Hybrid (`variant=blend`, `font=native` → Geist + Source Serif 4), нейтральні Light/Dark основи з Notion-акцентами, Gradient timeline із чорним темним інтервалом, нейтральні Moon durations/icons, compact status backgrounds, прибраний Welcome-link Home і зайві останні розмежувачі. Наукові формули, часові межі й fixture data не змінювалися.

## Таблиця WQA

| ID | Статус | Відтворення (before, baseline) | Причина | Мінімальне виправлення | Після (after) |
| --- | --- | --- | --- | --- | --- |
| WQA-01 P1 | **done** | Field 375: Home Open planner, Plan Save plan, Plan Apply changes, Library Save rig — чорний текст на `#AA0000`: default **2,7092:1**, hover (filter `brightness(.87)`) **2,2573:1**, pressed **3,699:1** | Field `action` `#AA0000` у парі з чорним `on-action`; hover затемнює фільтром | Лише Hybrid Field: `--action` = чинна роль `text-primary` `#FF0000` у телефоні, Home-концепті, Home-листі та planner-діалогах; hover — підкреслення замість затемнення; pressed — наявне selection-заповнення | Усі 5 дій (включно з діалоговим `Discard edit`) у трьох станах: default/hover **5,252:1**, pressed **4,6039:1** (`#FF0000` на `#330000`; діалог — 5,252:1), opacity 1, без інших фільтрів, лише red/black, кнопки enabled |
| WQA-06 P2 | **done** | Home → Observing site і Choose a night, 375/412: Cancel/Apply **339×144** / **376×144**, `flex: 1 1 144px` | `styles.css`: рядкова `flex-basis:144px` із вищою специфічністю перемагала column-правило й ставала вертикальною висотою | Прибрано лише `flex:1 1 144px` зі старого phone-detail правила; наявне column-правило `flex:none;width:100%` тепер діє | **339×48** / **376×48**, full width, один рядок; candidate rows і stacked-дії confirmation-адоптера мають висоту вмісту ≥48 |
| WQA-02 P2 | **done** | Чистий контекст: example Plan `Saved` → лише Weather A→B → Plan і Home **`Saved · changed`** + «Settings defaults differ from the saved budget»; та сама хибна причина при справжньому редагуванні block; повернення Planning до 5 s/15% і legacy-запис без snapshot теж показували `Saved · changed` | План без `budgetSnapshot` порівнювався з `{}`, а причина — з історичним fixture-бюджетом, а не з ефективним бюджетом «без Settings-запису» | `plan.js`/`app.js`: для плану без snapshot база порівняння — той бюджет, який він показував без Settings-запису (Hybrid: початкові Planning defaults; інші концепти: example budget). План зі snapshot порівнюється, як і раніше, зі snapshot. Без примусового Save, без створення snapshot, без blanket `dirty=false` | Weather A→B: Plan і Home `Saved`, без причини, запис плану не створено. Справжня зміна Planning (5→6 s) на snapshot-плані й на початковому прикладі — `Saved · changed` з причиною; повернення до 5 s — `Saved`; override плану — `Saved · changed`; редагування block — `Saved · changed` без хибної причини; legacy settings + legacy plain-запис без snapshot — `Saved`, запис не переписано |
| WQA-03 P2 | **done** | Field Weather Inspect an hour (A і B) та Settings Planning range: червоний thumb, світла native доріжка — **2536/2470** не-червоних пікселів, max G/B **239** | `accent-color` не перефарбовує native track | Лише Hybrid Field: `appearance:none` із track `border-control` `#880000`, thumb `text-primary` `#FF0000` 24 px, червоний focus-outline; forced-colors повертає `appearance:auto` | Raster: **0** не-червоних пікселів (max G/B 0), thumb присутній; ArrowRight/Home/End, pointer, min/max/step, selected hour і Settings-значення працюють; Light/Dark лишили native range і сині accent `#0075DE`/`#62AFF3` |
| WQA-04 P2 | **done** | Plan → Edit block → зміна Frames → X → `Discard this edit?`: phone 375 у студії 1200 — краї **1,5 / 1,5 px** (Light/Dark/Field); те саме для `Unsaved changes` і `Plan this night?` | `.planner-page dialog` рахував `calc(100% − 40px)` від viewport студії | `hybrid-ui.js` публікує видимий прямокутник телефону (`--phone-left/right/top/bottom/width/height`, ResizeObserver + resize/scroll); `plan.css` розміщує planner-діалоги в ньому з наявними 20 px краями й `max-width:372px`; без змінних — попередня поведінка | 375 і 412 у Light/Dark/Field: **20,0 / 20,0 px**, ширина 335 / 372, усередині телефону, дії ≥48 px, без horizontal overflow; вузький host 375: 20 / 20. Keep editing зберігає незастосоване поле, Discard edit не змінює draft, Cancel лишає changed draft, Adopt Cancel закриває без вибору |
| WQA-05 P2 | **done** | Weather B, scroll до Wind/gusts і Precipitation (Light 375, Dark 412, partial): верхню вісь прокручено, у нижніх панелях **0** часових підписів | Одна верхня `.wx-time-axis` у горизонтальному scroller; sticky в такому контейнері неможливий | `weather-variants.js/.css`: панелі 2–5 повторюють години наявної осі в тих самих 48 px колонках (`aria-hidden`, вісь лишається єдиним селектором); selected hour дзеркалиться в кожному рядку | Під Wind/Precipitation видно години, центри збігаються з віссю (≤1 px) при `scrollLeft` 0 і 96; selected hour 2 позначено на осі й у кожній панелі; path-дані всіх графіків, gaps `?` і шкали ідентичні before/after; A overview і компактний Home без змін |

## Що й чому змінено

- `design/home-lab/hybrid-refinement.css` — WQA-01 (Field primary pair і hover) та WQA-03 (Field range), лише під `html[data-theme=field]` + Hybrid; поруч із наявними Field radio/checkbox правилами.
- `design/home-lab/styles.css` — WQA-06: прибрано перенесену з рядкової композиції flex-basis.
- `design/home-lab/plan.js`, `design/home-lab/app.js` — WQA-02: спільна логіка бази порівняння для плану без snapshot (`unsnapshottedBudget`, `usableOf`) у Plan і такий самий розрахунок для Home-мітки.
- `design/home-lab/hybrid-ui.js`, `design/home-lab/plan.css` — WQA-04: розмір і позиція planner-діалогів від фактичного телефону.
- `design/home-lab/weather-variants.js`, `design/home-lab/weather-variants.css` — WQA-05: годинні підписи під нижніми панелями й синхронізація selected hour.
- `design/home-lab/scripts/check_web_qa_fixes.cjs` — новий цільовий регресійний скрипт (`CULMINA_QA_PHASE=before` записує відтворення без падіння; за замовчуванням перевіряє й падає при будь-якому провалі або page error).

Відхилення від початкового плану, виявлене під час фактичного перегляду: після першого after-прогону скриншот Field-діалогу показав, що `Discard edit` у planner-діалозі (поза `.android-device`) ще мав `#AA0000`. Scope WQA-01 розширено на `.planner-page dialog`, і цей стан додано до скрипта. Before-прогін виконано до цього доповнення, тому числового before для діалогової кнопки немає; її старий стан видно на `before-WQA04-discard-field-375.png`. Так само перевірку обчисленого focus-outline (WQA-03) додано після before-прогону.

## Точні перевірки

Preview: `python design/home-lab/scripts/serve_preview.py --port 4197` (loopback, `Cache-Control: no-store`). Chromium із pinned Playwright 1.64.1 через `browser_toolchain.cjs`, нові ізольовані контексти з демоданими, `deviceScaleFactor=1`, zoom 1, текст 1; студія 1200×1000, ширина самого телефону 375/412 задавалася inline-стилем контейнера і перевірялася DOMRect (як у QA `support.cjs`).

| Перевірка | Результат |
| --- | --- |
| `CULMINA_PREVIEW_URL=http://127.0.0.1:4197/ CULMINA_QA_PHASE=before node design/home-lab/scripts/check_web_qa_fixes.cjs` на baseline | Відтворено всі 6: провалено 53 перевірки (WQA-01 12, WQA-06 10, WQA-02 6, WQA-03 5, WQA-04 5, WQA-05 15); page errors 0 |
| Той самий скрипт після виправлень (фінальна версія) | **PASS**, exit 0: WQA-01 49, WQA-06 20, WQA-02 16, WQA-03 22, WQA-04 60, WQA-05 32 — разом 199 перевірок, 0 провалів, page errors 0 |
| `node --test design/home-lab/scripts/check_bridge.mjs design/home-lab/scripts/check_hybrid_defaults.mjs` | 9/9 pass (snapshot boundaries, budget assumptions, backup rollback) |
| `check_hybrid_field_controls.cjs` (`CULMINA_EVIDENCE` у temp) | pass: Field radios/checkboxes, keyboard, persistence, forced-colors fallback, без overflow при 375/412 × 100/125/200% |
| Копія `check_notion_adoption.cjs` з base 4197 і виводом у temp (щоб не переписати відстежувані докази) | pass, 13 cases: Weather A/B setting, legacy/restore, Light/Dark/Field ролі, Plan/Logbook/Library/Settings smoke, page errors 0 |
| Копія `check_palette_comparison.cjs` з виводом у temp (спільний `weather-variants.js`) | pass, 44 cases, min text 5,744:1, page errors 0 |
| `node --check` для `plan.js`, `app.js`, `hybrid-ui.js`, `weather-variants.js`, нового скрипта | OK |
| `git diff --check` для змінених web-файлів | без whitespace-помилок |

Фактично переглянуто: before/after Field block editor і діалог (WQA-01/04), Home site picker 375 (WQA-06), Plan після Weather B (WQA-02), Field range before/after і focus (WQA-03), Wind Light 375, Precipitation Dark 412 і partial Light 375 (WQA-05).

## Обмеження та невирішене

- Лише Chromium при 100% тексту; 125/200% для нових правил окремо не проганялися (окрім наявного Field-controls скрипта). Firefox-псевдоелементи `::-moz-range-*` написані, але не перевірені.
- WQA-01: pressed-стан у телефоні 4,6039:1 — вище порогу 4,5, але з невеликим запасом. Field як ціла тема не оголошується WCAG AA; документований secondary/tertiary tradeoff (`#AA0000`/`#880000` для тексту) не розширено й не змінено. Track range `#880000` — допоміжна межа; значення передає червоний thumb.
- `tokens.json` не змінювався: Field `action` `#AA0000` і примітка «deliberately dimmer» лишаються для інших концептів; для Hybrid Field primary тепер діє override у `hybrid-refinement.css`. Це FOLLOW-UP для документації токенів, не блокер.
- Не запускався застарілий `check_hybrid_corrections.cjs`: він клікає навмисно прибраний Home `[data-action=welcome]`. Confirmation-адоптер WQA-06 перевірено через тимчасово доданий у тестовому контексті тригер того самого діалогу.
- Повторний загальний аудит, 200%-прохід, Flutter/native міграція, Android-перевірка й owner-приймання не виконувалися і не заявляються.

## Докази та коміт

- Нові докази: `design/home-lab/evidence/qa-fixes-2026-10-22/` — `before-qa-fixes.json`, `after-qa-fixes.json` (усі виміри та повідомлення перевірок) і 53 PNG (26 `before-*`, 27 `after-*`; додатковий after — Field-діалог `Discard edit`) для кожної WQA.
- Вихідні QA-докази: `design/home-lab/evidence/independent-final-qa-2026-10-22/` (без змін).
- Один локальний коміт на `develop` містить лише scope-файли: 8 web-файлів, новий скрипт, нові докази й цей звіт. Його SHA наведено у фінальній відповіді сесії (не вписується сюди, щоб не вигадувати майбутній хеш). Push не виконувався.
