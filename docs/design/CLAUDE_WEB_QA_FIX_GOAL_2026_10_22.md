# Claude /goal: виправлення підтверджених web QA знахідок

## Доручення власника і межі

Нове доручення власника від 2026-10-22: зробити коміт поточного результату, передати Claude контекст аудиту + QA, запустити виправлення проблем у режимі `/goal`, а потім надати його звіт. Виконай один обмежений пакет **WQA-01…WQA-06** із підсумкового QA. Попередній звіт рекомендував почати з трьох; цей запуск охоплює шість уже підтверджених проблем за новим дорученням, без нових пошукових аудитів.

Ти — єдиний виконавець виправлень. Не запускай інших агентів чи повторний незалежний аудит. Головний Codex передасть власнику твій фактичний звіт і перевірить відповідність diff цьому дорученню. Не стверджуй owner-приймання еталона або готовність Android.

## Обов'язкове читання

1. `CLAUDE.md`: чинні інструкції та Verification Policy, особливо V3–V8. Початок `docs/refinement/PROGRESS.md` тільки для контексту; цей web-пакет не активує roadmap F01–F26/G1–G4.
2. `docs/design/INDEPENDENT_WEB_FINAL_QA_2026_10_22.md` повністю — головний перелік знахідок, відтворення, пріоритети, поточні owner-рішення та обмеження доказів.
3. `docs/design/WORKFLOW.md`; `.agents/skills/culmina-design-{rules,tokens,spacing,components}/SKILL.md`; typography skill лише якщо зачіпатимеш текстові ролі. Використай наявний Impeccable skill, якщо доступний, без init/rebrand/new-design workflow.
4. `docs/design/HYBRID_NOTION_ADOPTION_2026_10_22.md` і тільки релевантні розділи `docs/DESIGN_SYSTEM.md`. Інші історичні аудити не перечитуй.

Відтворювані вихідні докази скопійовано у `design/home-lab/evidence/independent-final-qa-2026-10-22/`. Початкові повні матеріали також лишаються тут:

`C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/`

Збережи вихідний QA незмінним як історичний доказ. Пиши власний результат у **`docs/design/CLAUDE_WEB_QA_FIX_RESULT_2026_10_22.md`** українською, а нові докази — у **`design/home-lab/evidence/qa-fixes-2026-10-22/`**.

## База та збереження чужої роботи

Перед стартом прочитай `git status --short`, `git log -2 --oneline` і поточні файли. Безпосередньо перед твоїм запуском Codex комітить reviewed web baseline + QA + це доручення на `develop`. Це базовий коміт для твого diff. Поточні web-файли включають раніше незакомічені прийняті зміни власника; не відновлюй HEAD до їх появи.

Поза твоїм scope є вже наявні dirty Flutter-файли:

- `lib/presentation/screens/equipment/equipment_editor.dart`
- `lib/presentation/screens/target/target_selection_screen.dart`
- відповідні два файли тестів у `test/presentation/screens/`
- наявні untracked `docs/design/migration/evidence/*`.

Не редагуй, не stage і не коміть їх. Не використовуй `git add .` / `git add -A`, reset, clean, checkout, stash, pull, rebase або force push. Не роби push. Дозволено один цільовий **локальний** commit твоїх перевірених виправлень, регресійних перевірок, нового звіту та нових доказів; stage лише явні дозволені шляхи.

Не змінюй Flutter/native код, production theme, залежності, tooling pin, MCP/CLI конфігурацію, roadmap чи CI. Не встановлюй пакети/плагіни/інструменти. Не працюй з телефоном, ADB або Flutter-тестами. Не відкривай браузерний профіль/сховище власника. Використовуй тільки нові ізольовані Chromium contexts із демоданими.

## Заморожені візуальні й функціональні рішення

- Лише чинний Hybrid (`variant=blend`). `font=native` або правильний `font=Geist`, не lower-case `font=geist`: останній у Conditions/Workspace викликає інший fallback.
- Geist для UI, чинні Source Serif 4 editorial-ролі. Нейтральні Light/Dark основи, Notion-inspired data/status акценти. Не замінюй палітру Radix/Tweakcn/іншим study-кандидатом.
- Основний timeline — Gradient, black dark interval, синьо-блакитні день/сутінки; чинні Moon lanes, times, cursor, unknown spans збережені.
- Новіші прямі owner-рішення: Moon durations/icons нейтральні; compact status backgrounds у Logbook list/detail; Welcome & Setup link та зайві останні розмежувачі Home/Settings **навмисно прибрані**, не повертати їх за старими звітами.
- Home Weather компактний; Weather A/B вибирається через Settings. Не додавати нові метрики, погодні оцінки чи numeric MF.
- Зберегти Save/Apply/Cancel/Discard/draft та selected-night semantics; unknown не перетворювати на 0. Ніяких змін наукових формул/часових меж/fixture data для отримання PASS.

## Шість проблем і acceptance criteria

### WQA-01, P1 — primary Field action contrast

Зараз активний `Apply changes` має black text / `#AA0000`, opacity 1, 16 px / 600: 2.7092095:1.

- Мінімально виправ shared browser primary action pair у red/black; normal text має >=4.5:1 у default і наявному hover/pressed стані після всіх ефектів. Перевір репрезентативні Home Open planner, Plan Save/Apply і Library Save.
- Не відключай кнопку для винятку контрасту; не розширюй documented secondary/tertiary Field tradeoff. Не змінюй Light/Dark action palette.
- Виміряй фактичні foreground/background/opacity/filter. Не оголошуй усю Field тему WCAG AA.

### WQA-06, P2 — Home picker 144px actions

Home → site/night picker: `flex:1 1 144px` використано в column, кожна коротка дія заввишки 144px.

- При 375 і 412 CSS px, 100% text, Cancel/Apply зберігають full width та >=48px target, але не тягнуть 144px вертикальної flex-basis.
- Виправити причину каскаду, не текст/семантику; перевірити обидва пікери й representative candidate/confirmation adopter для regression.

### WQA-02, P2 — false dirty від Weather presentation

Чистий контекст: example Plan `Saved`, без budgetSnapshot; змінити тільки Appearance Weather A→B; повернутися до Plan: неправдивий `Saved · changed` і reason про зміну budget.

- Display-only зміна не змінює effective budget, не робить Plan/Home dirty та не переписує plan/draft/saved snapshot.
- Врахувати initial defaults і legacy payload без snapshot, зберігши справжній dirty state після зміни Planning і після справжньої зміни plan.
- Не маскувати симптом примусовим Save/створенням budgetSnapshot при appearance change або blanket `dirty=false`.
- Перевірити clean initial example, saved plan зі snapshot, legacy settings/payload, справжню Planning зміну, plan override та реальне редагування block у межах зміненого контракту.

### WQA-03, P2 — neutral native range у Field

Weather Inspect an hour має red thumb, але світлу native track; `accent-color` недостатньо.

- Застосувати чинні red/black roles до track/thumb/focus у Hybrid Field, не ламати Arrow keys, selected hour, min/max/step або pointer interaction.
- Перевірити Weather і representative Settings Planning range, normal Light/Dark та Field. Не ламати вже red-only radios/checkboxes.
- Browser raster/control check має підтвердити відсутність білих/сірих частин у звичайному Field rendering; forced-colors system fallback не називати defect.

### WQA-04, P2 — modal gutter від ширини студії

Plan Discard dialog 372px при phone375 дає тільки 1.5px країв, при412 —20px; % рахується від host viewport.

- Розмір/позиція пов'язані з фактичним phone container, збережені змістовні наявні крайові поля й >=48px targets, без host-viewport spill/overflow.
- Перевір 375/412 у студії1200px, representative narrow host, light/dark і Field smoke для shared CSS; не змінюй choices/focus/Cancel/Discard/Save.
- Не нав'язуй нову spacing grid; відтворити чинний intended phone-sized overlay rhythm.

### WQA-05, P2 — нижні Weather B без часу

При scroll до Wind/Gusts/Precipitation єдина верхня x-axis зникає; нижні графіки не мають часових підписів.

- Нижні панелі повинні читатися з видимою часовою прив'язкою при вертикальному й наявному горизонтальному scroll. Повторно використай existing hour axis або мінімально збережи її доступність у композиції.
- Зберегти shared x positions, units, independent y scales, selected-hour/exact facts, gaps, preceding-hour semantics, A overview та компактний Home.
- Перевір реальний render нижніх charts при375/412 Light/Dark і partial fixture; не змінюй samples і не підставляй unknown значення.

## Цільова перевірка й stop condition

Не запускай повторну повну web-аудит матрицю або 200% прохід. Один пакет: reproduce кожної WQA → minimal fix → targeted regression на її criteria і affected shared adopters. Коротка репрезентативна перевірка інших основних екранів лише якщо їхній shared CSS/поведінка змінюється.

Використовуй наявний `design/home-lab/scripts/browser_toolchain.cjs` (pinned Playwright1.64.1). Preview: `python design/home-lab/scripts/serve_preview.py --port <вільний loopback порт>`. Не вважай 375px ширини вікна браузера 375px телефоном: у студії1200 задавай і вимірюй саме phone375/412, zoom1/text1. Якщо API документація потрібна — current Context7; документація Playwright/Claude уже була fetched у головному чаті, не встановлюй нічого.

Скріншоти before/after потрібні насамперед для шести findings; **фактично відкрий/переглянь** нові affected renders, не обмежуйся screenshot generation чи code inspection. Збережи computed geometry/colors, browser failures і точні результати targeted checks. Додай змістовні focused regressions у наявному стилі, не тести, які лише повторюють literal implementation.

JS syntax і scoped `git diff --check`; наявні Node/browser checks обирай за реальними dependencies. Якщо обґрунтоване розширення перевірки потрібне, коротко поясни його. Не запускай Flutter/full CI. Не запускай інші агенти.

Goal досягнуто лише коли всі шість WQA мають відтворення, мінімальне виправлення, passing targeted evidence, новий український звіт і локальний commit тільки scope-файлів. Фінальна відповідь: статус, таблиця WQA done/not done, що/чому змінено, точні checks/limits, commit SHA, report/evidence paths, решта dirty Flutter files збережена. Не називай owner-приймання PASS.

Якщо реальний зовнішній blocker робить criterion неможливим, не вигадуй PASS: збережи роботу, напиши **PARTIAL_WITH_ATTENTION** з причиною й точними незавершеними IDs; припини futile loops. Не запитуй повторно дозволу на рутинні кроки всередині цього scope, але не розширюй permissions і не обходь автоматичну відмову. Після report/commit зупинись. Ніякого push чи наступного етапу.
