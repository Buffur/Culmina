# Незалежний підсумковий QA вебеталона Culmina — 22.10.2026

**Вердикт: потребує конкретних виправлень перед прийманням і фіксацією вебеталона.**

Підтверджено **1 P1 та 5 P2**. Найважливіші: недостатній контраст активної основної дії у Field, кнопки заввишки 144 px у Home-пікерах та неправдивий `Saved · changed` після зміни лише подання Weather. Основний напрям дизайну зберігся; підстав починати дизайн заново немає. Це висновок про браузерний кандидат при 100%, а не про готовність Android-релізу.

## А. Версія, метод і фактичне покриття

- Гілка `develop`, HEAD `a59483730262e2663a10d5055342211839ab8650`.
- Перевірено **локальні поточні файли, включно з наявними dirty/untracked змінами**, а не тільки HEAD. На початку вже були зміни web, Flutter і тестів; вони збережені.
- Основний кандидат: `variant=blend`, стандартний вибір шрифту `font=native` → Geist для UI та Source Serif 4 для визначених editorial-заголовків; актуальні `hybrid-refinement.css`, `hybrid-data-tokens.css`, `notion-hybrid.css`.
- Окремий наявний preview-handler запущений на `127.0.0.1:4193`. HTTP-відповіді семи ключових HTML/CSS/JS файлів зіставлено з диском за SHA-256: усі збігаються, `Cache-Control: no-store`. Свіжі непостійні Chromium-контексти; профіль і сховище власника не читалися.
- Зафіксовано 128 runtime/font/asset файлів. Наприкінці всі 128 мали ті самі хеші. Сукупний fingerprint маніфесту: `3ac4296acd6cfea8771cc8cf67be6de4ac89d72b591e7051d1207ceda7b7f6b8`. Це ідентифікатор перевіреного кандидата, **не акт фіксації/приймання**.
- Chromium із наявного pinned Playwright 1.64.1, `deviceScaleFactor=1`, CSS zoom `1`, текст `1`. Ширина вікна студії 1200 px; ширина **самого телефону** задавалася 375/412 px і перевірялася через DOMRect. Змінювалися лише розміри браузерного тестового контейнера; код і токени не редагувалися. Початковий пробний viewport 375 px давав телефон 319 px; такий розмір не зараховано до цільового покриття.

| Композиція | Заліковий перегляд | Сценарії / дочірні композиції |
| --- | --- | --- |
| Home / Tonight | Light 375; Dark 412, включно з прокручуванням | План, компактні умови, таймлайн; site/night/candidate пікери; статуси saved/changed |
| Plan | Light 375; Dark 412 | Контекст, Target/Rig single-choice пікери, block editor, calibration, assumptions, розкриті budget/gain; Apply, Save, validation, Discard, retry |
| Night | Light 375; Dark 412 | Точні часові розкриття, Sun/twilight, Dark starts/ends і клавіатурний крок |
| Moon | Light 375; Dark 412; Field 375 | Відповідь, календар і таймлайн; окремо no-dark при Light 375 |
| Weather A | Light 412; Dark 375; Field 375 | Рядки, покриття/давність/одиниці, coming nights; unavailable та partial при Light 375 |
| Weather B | Light 375; Dark 412 | П'ять графіків, спільні години, точні hourly facts, вибір 00:00, нижні панелі без видимої осі |
| Logbook | Light 375; Dark 412 | Detail, result editor, помилки результату, Save/reload, filters, progress by target; child-рендери переважно Light |
| Library | Light 375; Dark 412 | Rigs/Targets/Sites, catalogue/list/detail, три форми, українські довгі значення, metadata review/Apply/Discard; форми переважно Light 375 |
| Settings | Light 375; Dark 412 | Appearance, Planning, Privacy, Backup, About; помилка збереження/retry та Planning Cancel |
| Prototype backup | Dark 412 | Реальне завантаження JSON із власних демозаписів, review, Cancel, Confirm, екран результату |
| Порівняння компонентів | Light 375 | Візуально переглянуто Minimal / Gradient / Detailed на однаковому fixture; в усіх зберігся cursor `495` |

Фактичні рендери переглядалися, у довгих композиціях — із прокручуванням. Контактні аркуші показують послідовні позиції scroll, тому повторення заголовка на них не означає дубльований елемент у застосунку. Автоматичні виміри не підміняли перегляд.

Залікові Conditions/Workspace рендери використовують `font=native`. Ранні діагностичні відкриття з помилковим lower-case `font=geist` давали Manrope fallback у цих двох модулях: це помилка тестового URL, **не дефект погодженого default**. Відповідні композиції перевірено з коректним вибором; діагностичні PNG не доводять відповідність шрифту. Раннє false у перевірці Target/reload стосувалося пошуку назви всередині `main`, тоді як назва міститься в app bar; подальший перегляд збереженого detail підтвердив назву й координати. Помилки селекторів/очікувань не оголошені продуктовими дефектами.

**Межі:** не будувалася повна декартова матриця. Не всі форми й помилки перевірено в кожній темі та ширині. Не перевірялися 125/200%, усі старі не-Hybrid концепції, кожна альтернативна палітра, повний catalogue/design-code workbench, кожна file/geolocation edge case, усі keyboard/hover/pressed комбінації або touch-жести. Не виконувались Flutter-тести, CI, встановлення інструментів, телефонні дії, наукова валідація чи оцінка Android performance. Процесів/даних власника не зупиняли й не очищали.

Докази цього запуску: [каталог вимірів і скриншотів](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa), зокрема `observations.json`, `source-manifest-before.json`, `served-freshness.json`, `source-integrity.json`, `git-status-preserved.txt`. Це нові докази, відокремлені від попередніх archive/evidence наборів. Доказові helpers залишені там само поза кодом проєкту.

## Б. Підстава вердикту

У Light/Dark звичайна композиція восьми основних екранів читабельна, істотного горизонтального переповнення основних телефонних контейнерів не виявлено. План зберігається, editor Apply відокремлений від Save, демозаписи Library/Logbook повторно відкриваються. Нейтральні основи та обрані акценти узгоджені.

Однак **WQA-01** є виміряним провалом контрасту потрібної основної дії при 100%. **WQA-06** — відтворений збій розміру керування, а **WQA-02** — відтворена недостовірність стану збереження. Ці результати не дозволяють назвати актуальний кандидат завершеним еталоном. Решта трьох знахідок наведені окремо, без автоматичного дозволу їх виправляти.

## В. Матриця актуальних вимог і рішень

Код є предметом QA. Звіти використано як записи вимог із зазначенням їхнього рівня доказовості. Найновіші прямі повідомлення власника в доступному чаті `01a160b5-4e44-7191-90f9-be213b3d40a3` перевірено окремо; не вимагалося відновлювати скасовані речі.

| Вимога | Джерело / статус джерела | Підсумок | Доказ / уточнення |
| --- | --- | --- | --- |
| Поточний Hybrid; не починати новий дизайн | Поточна ціль; WORKFLOW; п'ять local design skills | Виконано в межах QA | Перевірено incumbent; реалізаційних змін немає |
| Geist; читабельні українські glyphs/числа | Чинний `tokens.json.variants.blend`; записане попереднє рішення Geist | Виконано у вибірці | CDP показав custom `Geist-Medium` для `QA · Українська Її Єє Ґґ · 135 mm × 60 s −18°`; `font-evidence.json` |
| Notion-inspired нейтральна основа та вибірковий колір | Пряме «Зроби кольорову схему як у Notion», turn `01a16330-f40b-7883-8661-603196bfd75f`; `HYBRID_NOTION_ADOPTION_2026_10_22.md` | Виконано у переглянутому UI | Weather/графіки — сині, звичайні поверхні/дії — нейтральні, статусові підкладки компактні |
| Не трактувати Radix/Tweakcn/Happy Hues як прийняту повну тему | Поточна ціль; `HYBRID_PALETTE_COMPARISON_2026_10_22.md` | Виконано | Основні сторінки використовують Notion adoption; інші джерела лишаються study-кандидатами |
| Три варіанти таймлайна на тих самих даних | `HYBRID_COMPONENT_STUDY_2026_10_22.md`, §C | Виконано | Три реально перемкнуті рендери, 375 px, спільний cursor; `timeline-three-variants.png` |
| Синьо-блакитний напрям із чорним темним інтервалом; обраний Gradient | `HYBRID_WEB_FIXES_2026_10_22.md`, latest refinement; `HYBRID_NOTION_ADOPTION_2026_10_22.md` | Виконано у вибірці | Поточні Home/Night/Moon рендери. Старий темно-синій колір ночі перекритий новішим записаним рішенням, а не є невиконаною вимогою |
| Мала семантична палітра Plan/Weather/Moon | Adoption + новіше пряме «прибери тут колір», turn `01a1633e-c91a-7701-946a-b4e161c19b3a` (Moon) | Частково | Weather blue/secondary neutral, gain blue, Moon durations/icons нейтральні. Field має WQA-01/03; не вимагати повернути фіолетовий Moon зі старої таблиці |
| Weather A/B на однакових даних; вибір у Settings; Home компактний | `HYBRID_NOTION_ADOPTION_2026_10_22.md` | Частково | Обидва подання працюють і preference зберігається; WQA-02/05 |
| Контраст і red/black Field; зберегти вузький secondary/tertiary виняток | Поточна ціль §8; `DESIGN_SYSTEM.md` §2; token skill | Частково | Light/Dark sampled pairs проходять; WQA-01/03. Прийнятий виняток допоміжного тексту не поширено на основну дію |
| Групування й реальні відступи, >=48 px керування | Поточна ціль §6; spacing/components skills | Частково | Home: 24 + 1 + 24 = 49 px між дією та heading умов; звичайні gutters/форми збережені. WQA-04/06 |
| Compact status backgrounds у списку та detail | Прямі turns `01a1633f-b707-7721-b06d-eb8b19ea8f59`, `01a16341-d6b4-70e0-be9a-e006147dc80f` | Виконано у вибірці | Переглянуті Logbook list/detail, Saved / Partly / Completed / Not done / Not recorded; слова не замінені лише кольором |
| Прибрати Home Welcome & Setup і зайві останні розмежувачі | Прямий turn `01a16343-5a2d-7302-b880-44aad99fb911`: «Прибери ... перехід на Welcome & Setup це одноразовий екран» | Виконано; попереднє збереження переходу скасовано | Поточний Home не має `[data-action=welcome]`, Settings закінчується без зайвої лінії. Старий звіт про reachable Welcome тут застарів |
| Сім'я іконок, застосування та ліцензії | Component study §E; локальні `icons.js`, `icons/lucide/README.md`, LICENSE | Реалізовано; окреме owner-схвалення саме сім'ї не підтверджено | Сім data glyphs Lucide, 20×20 / stroke 1.7, локальні SVG з ISC/Feather MIT; навігаційні glyphs мають окремі ролі/розміри. Немає підстав автоматично замінювати всі старі іконки |
| Опрацювання п'яти вихідних зображень | Оригінали `d3b0c44b-fef2-4096-85f1-53b71a60c743/image-1.png` … `image-5.jpg`; component-study photo map | Переважно виконано; не повне owner-приймання | Усі п'ять оригіналів особисто відкриті в цьому QA. Див. зіставлення нижче |

П'ять зображень: **1** — повторний бренд прибрано, Field поруч із заголовком; стару вимогу залишити Welcome-посилання перекриває новіший прямий запит. **2** — іконка перед назвою, дані зліва, підписані endpoint-дії; залишено змістовні розмежувачі. **3** — Moon-free answer/тривалість співіснують без накладання; календарні дати/фази вирівняні; при 375 px календарна навігація закономірно переноситься. **4–5** — A/B переосмислюють наявні погодні дані; це не згода на нові UV/AQI, daily high/low чи gauge-функції. Недолік часової прив'язки B зафіксовано як WQA-05. Кожна позначена лінія на фото не інтерпретувалася як наказ прибрати всі межі.

## Г. Підтверджені проблеми

### WQA-01 — P1. Недостатній контраст активної основної дії у Field

**Де:** Plan → Edit block, Field, 375 px, 100%, default стан кнопки `Apply changes`; без hover, disabled=false. Спільна пара `action/on-action` використовується основними діями прототипу.

**Спостереження й вимір:** текст `rgb(0,0,0)` на `rgb(170,0,0)` (`#AA0000`), opacity 1, 16 px / 600. Контраст **2,7092095:1** за необхідних **4,5:1**. Це звичайний текст, не large text; control активний. На скриншоті напис істотно слабший за навколишні основні значення.

**Порушення:** поточна ціль §8, WCAG 2.2 SC 1.4.3. Документований Field tradeoff стосується secondary/tertiary. У `tokens.json` action названо deliberate dimmer prototype, але ця примітка коду не є підтвердженим owner-виключенням для потрібної основної дії і не змінює виміряний провал WCAG.

**Відтворення:** відкрити Plan `variant=blend&font=native&theme=field&scale=1`; телефон 375; Edit першого block; відвести pointer із кнопки; прочитати Apply та computed colors.

**Мінімальний напрям виправлення:** виправити тільки пару основної Field-дії в межах red/black, забезпечивши читабельний напис; не підвищувати глобально secondary/tertiary і не додавати сторонні відтінки. Окремо перевірити її наявний hover/pressed після зміни.

[Скриншот](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F01-field-primary-action.png) · [computed styles](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/field-action.json).

### WQA-06 — P2. Home-пікери розтягують Cancel/Apply до 144 px

**Де:** Home → Observing site або Choose a night, Light, 375 і 412 px, 100%.

**Спостереження й вимір:** кожна з двох коротких дій має **144 px висоти**, група — **300 px**. При 375 px кнопки мають 339×144 px. Це 3× звичайної 48 px висоти, хоча текст займає один рядок; форма різко змінює щільність порівняно з Plan та Library, а порожня площа кнопок конкурує з вибором місця/ночі.

**Причина:** `styles.css:53` задає `.dialog-actions > * { flex:1 1 144px }` для рядка, а `styles.css:56` переводить `.dialog-actions` у column. Ті самі 144 px стають вертикальною flex-basis. Це виміряний cascade/layout дефект, а не вимога нової spacing-сітки.

**Порушення:** поточна ціль §6/9; чинні spacing/components правила послідовних розмірів керування і змістовного групування.

**Відтворення:** Home wide → натиснути місце або ніч у верхньому context; подивитися Cancel/Apply та `getBoundingClientRect().height`.

**Мінімальний напрям:** для column-композиції прибрати перенесену з horizontal-layout flex-basis, зберігши full-width і >=48 px target; не перебудовувати сам сценарій.

[375 px](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F06-home-site-oversized-actions-375.png) · [412 px](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F06-home-site-oversized-actions.png) · `home-picker-geometry*.json`.

### WQA-02 — P2. Weather view створює неправдиве повідомлення про змінений бюджет

**Де:** чистий ізольований контекст, початковий example Plan без `budgetSnapshot`, Light 375; такий стан спостерігався також на Home і Dark 412.

**Відтворення:** 1) відкрити початковий Plan — `Saved`; 2) Settings → Appearance → B · Hourly charts, без змін Planning; 3) знову Plan. Тепер `Saved · changed`, `Settings defaults differ from the saved budget`, нижче `Changes are not saved yet`.

**Вимір/наслідок:** до і після — 120×60 s, needed 2 h 10 min, usable 4 h 15 min. Settings зберігає ті самі initial Planning defaults 5 s / 15%. Перший запис Display створює також settings payload; `plan.js:117` порівнює effective assumptions з відсутнім `budgetSnapshot` як `{}`. `settingsBudgetReason` порівнює ще й історичні fallback assumptions замість effective baseline, який уже показувався до Appearance. Дані плану не були втрачені; проблема у словах і dirty state. Не узагальнювати її на всі реальні збережені плани зі snapshot.

**Порушення:** чесне розділення saved/draft; adoption-контракт про незалежність Weather view від plan/draft; поточна ціль §9.

**Мінімальний напрям:** зіставляти effective бюджет до/після з урахуванням initial defaults та legacy відсутності snapshot. Не приховувати справжні зміни Planning. Не виправляти через примусовий Save при зміні вигляду.

[Скриншот](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F02-weather-setting-false-dirty.png) · [чистий before/after](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/weather-preference-dirty.json).

### WQA-03 — P2. Field Weather має світлу native slider-доріжку

**Де:** Weather → Inspect an hour, Field, 375 px, 100%, без hover.

**Спостереження:** червоний thumb/accent, але довга незаповнена доріжка світла/нейтральна. `appearance:auto`, `color-scheme:dark`, `accent-color:rgb(255,0,0)`; сам accent-color не перефарбовує всі частини browser-native range. Це не припущення за CSS — світлу лінію видно в актуальному рендері.

**Порушення:** чинне Field red/black правило, adoption і поточна ціль §5/8. Це інший компонент, ніж уже виправлені radio/checkbox; старий PASS останніх не закриває range.

**Відтворення:** Weather A → Field → прокрутити до Inspect an hour. Розмір range у перевірці 333×48 px.

**Мінімальний напрям:** оформити track/thumb/focus у наявних red/black ролях, зберігши native range semantics і клавіатуру; не додавати новий slider-модельний компонент без потреби.

[Скриншот](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F03-field-weather-range.png).

### WQA-04 — P2. Діалог залежить від ширини студії, а не телефону

**Де:** Plan → Edit block → змінити Frames → X → Discard this edit?, 100%, Field; той самий тип діалогу переглянуто також Light.

**Вимір:** у студії 1200 px dialog має постійні **372 px**. Телефон 375 → поля по **1,5 px**; телефон 412 → по **20 px**. Усередині залишається padding 24, але майже зникає зовнішнє відділення overlay від краю телефону при 375. Порівняно з наявним 20 px content gutter та 412-версією це помітний стрибок композиції.

**Причина/правило:** `.planner-page dialog` у `plan.css:25` має `width:calc(100% - 40px);max-width:372px`, але відсоток рахується від браузерного viewport, не phone. Порушено вимогу розрізняти студію й телефон та зберігати крайові відступи (§5/6), а не абстрактну нову 8 px сітку.

**Мінімальний напрям:** обмежити розмір/позицію цього overlay від фактичного phone rectangle з наявними поля́ми. Не змінювати Save/Discard/Cancel або padding тіла без причини.

[375 px](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F04-dialog-field-375.png) · [412 px](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F04-dialog-field-412.png) · [DOMRect](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/dialog-geometry.json).

### WQA-05 — P2. Нижні Weather B графіки втрачають видиму часову прив'язку

**Де:** Weather B, Light 375 і Dark 412, 100%; scroll до Wind/gusts та Precipitation.

**Спостереження:** п'ять панелей мають одну спільну верхню часову вісь. На нижніх графіках немає власних x-підписів або видимого selected-hour маркера. Після scroll вісь зникає, і користувач мусить пам'ятати позиції годин або повертатися нагору. Точні hourly facts нижче працюють — це workaround, а не відсутність погодних даних.

**Вимір:** `.wx-time-axis` position `static`; у збереженому стані її viewport y = −22,52…26,48, тоді як scrollport починається на y=352,67. Wind chart y=603,44…786,42 повністю видимий без жодних годин. Ширина graph-grid 384 px — штатний внутрішній horizontal scroller, не page overflow.

**Порушення:** поточна ціль §9 — зрозумілі часові інтервали графіків; declared purpose B — порівняння змін протягом ночі. Одиниці та series legends збережені, дефект стосується саме прив'язки до часу.

**Мінімальний напрям:** повторно використати існуючу часову вісь біля нижніх панелей або забезпечити її доступність у scroll-композиції; не змінювати дані, кількість панелей або часові інтервали.

[Скриншот](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/F05-weather-lower-charts-no-time-axis.png) · [геометрія](C:/Users/zalub/.codex/visualizations/2026/10/22/01a16345-37d5-7ea0-a084-eeec704c9df9/final-web-qa/chart-axis-geometry.json).

## Д. Типографіка, кольори, spacing і відповідність референсам

**Відступи.** У звичайному телефонному контенті збережено спільні ліві лінії, 20 px browser gutters; це локальна browser-композиція, її не підмінено production `AppSpacing.md=16`. Home Plan → Conditions: фактично 24 px margin + 1 px межа + 24 px padding, **49 px** button-to-heading. Це усуває раніше позначене злиття груп. Форми мають окремі label/input/hint/error, двоколонкові поля відступають від тих самих країв; Library footer у вимірі має 333 px ширини та дві кнопки 160,5 px з 12 px проміжком. Primary Save/Apply доступні біля нижнього краю; нормальне прокручування не оголошено перекриттям. Винятки — WQA-04/06.

**Шрифти.** Geist реально завантажений локально, variable face оголошений 400–700. CDP для української назви з науковими символами показав тільки custom Geist, без системного fallback. Переглянуто 22/500 app bar, 20/600 section headings, 16/600 labels та 15/400 values Plan, 13 px support і 12 px calendar/chart metadata; звичайні line heights допускають переноси. Source Serif 4 лишається визначеним editorial-акцентом, а не заміною гарнітури форм. Глобальне збільшення або заміна шрифту не потрібні. Однорядковий input довгої назви не визнано дефектом лише через внутрішній scroll.

**Контраст.** Методика — WCAG 2.2: [текст SC 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [нетекстові елементи SC 1.4.11](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html). Звичайний текст — 4,5:1, великий — 3:1; неактивні controls і декоративні межі мають відповідні винятки. Пороги не округлялися до PASS. Для текстових вибірок прозорі solid backgrounds накладалися source-over до непрозорої основи; gradient/ancestor-opacity випадки відокремлено від автоматичного PASS. WQA-01 має повністю непрозору пару без ефектів, тому її результат однозначний.

| Фактична пара / стан | Контраст | Поріг / висновок |
| --- | ---: | --- |
| Light support `#5A5955` / white | 7,0120:1 | 4,5; PASS |
| Dark support `#A5A5A3` / `#191919` | 7,1254:1 | 4,5; PASS |
| Виміряний мінімум звичайних solid-text пар у selected Light Plan/gain | 5,1795:1 | 4,5; PASS у вибірці |
| Мінімум sampled Dark Moon text | 5,0561:1 | 4,5; PASS у вибірці |
| Weather selected hour Light `#005BAB` / `#E6F3FE` | 6,0354:1 | 4,5; PASS |
| Weather selected hour Dark `#A6D2F3` / `#152D40` | 8,8669:1 | 4,5; PASS |
| Weather blue path Light `#0075DE` / white, opacity 1 | 4,5659:1 | 3; PASS |
| Weather blue path Dark `#62AFF3` / `#191919`, opacity 1 | 7,4894:1 | 3; PASS |
| Weather secondary solid/dashed paths Light / Dark | 7,0120 / 7,1254:1 | 3; PASS |
| Field secondary `#AA0000` / black | 2,7092:1 | Нижче AA; документований secondary tradeoff, не нова знахідка |
| Field active primary label black / `#AA0000` | 2,7092:1 | 4,5; **FAIL WQA-01**, поза secondary винятком |

Це не загальна WCAG-відповідність: не вимірювалися всі placeholder/hover/filter/gradient/overlay пари чи кожний нетекстовий стан. Бліді декоративні розділювачі не оцінювалися як обов'язкові control borders. Sky ramp не трактувався як фізична яскравість або оцінка якості; його межі й значення дублюються текстом і lane-позицією.

**Референси.** Підтверджена відповідність Notion-принципам: нейтральні великі поверхні, текстова ієрархія, компактні status tags, локальні сині data accents, явні розкриття. Apple-подібна просторість реалізована через відокремлені семантичні секції; WQA-06 — випадковий надлишок простору, не корисна просторість. Material-принципи single/multiple choice, action labels і readable failure/retry збережені; реальна native-поведінка цим не доведена. Linear-подібні рівні колонки/вирівнювання значень є у Plan та Logbook; WQA-04/05 порушують послідовність у своїх контекстах.

Синій `#0075DE` описаний попереднім дослідженням як спостереження marketing-сайта Notion; dark adaptations, статусові та sky кольори — **власна адаптація Culmina**, не «офіційні HEX Notion». Точна pixel-match відповідність поточним live-сайтам Notion/Apple/Google/Linear не є критерієм цього запуску і не заявляється. Фото та локальні погоджені контракти не підмінені суб'єктивним рейтингом. Нових альтернативних дизайн-напрямів не запропоновано.

## Е. Перевірені взаємодії, допоміжні CLI й наступний крок

Реально виконано:

- Library rig: порожня форма → required errors; введення назви українською та сенсора/оптики → Save → reload/detail. Target: out-of-range RA/Dec → errors → коректні координати → Save → збережений detail. Site: десяткова кома → Save → reload із правильними координатами/зоною.
- Metadata: sample review → Apply checked values змінює draft; Cancel викликає guard; Cancel у guard зберігає editor, Discard виходить. Це позначений walkthrough, не читання реальних camera headers.
- Plan: Frames=0 → error; 121 → Apply → Save/reload; unapplied 122 → Keep editing, потім Discard без переносу полів; simulated save failure → Retry save. Announcement після очікування має opacity 0, хоча текст лишається в DOM.
- Logbook: відсутній outcome та від'ємний frame count → errors; Partly/75 → Save/reload, інтеграція 1 h 15 min і українська note збережені; filters/progress відкрито й переглянуто. Результат відокремлений від saved-plan snapshot.
- Settings: Weather A/B зберігається, перехід до Weather показує вибране подання; simulated save failure явно позначає shown-but-not-saved, Try again зберігає; Planning Cancel лишає persisted settings без зміни.
- Backup: реальний download демо JSON → review → Cancel; повторний review → Confirm → видимий success/reload screen. Це браузерні записи, не Flutter database backup.
- Timeline: обидві endpoint-дії; ArrowRight 495 → 500 (5 хв); exact-time disclosure. Weather вибір index 2 → selected=true, summary `Hourly values 00:00`, точні facts для 20 Oct, 00:00 GMT+3.

Це обмежені browser-сценарії, не запуск повного автотестового набору. Не кожен result/outcome, camera class, геолокаційна помилка або import формат перевірявся.

**CLI внесок без повторних аудитів:**

- Claude CLI справді запущено один раз, read-only `Read` tools, plan mode, без MCP і без делегування. Вузьке завдання — витягти джерела шести попередніх вимог. Отримано непорожню відповідь, `end_turn`, без error. Це не незалежний UI-verdict; новіші прямі user-повідомлення звірено головним рев'юером після цього витягу.
- AntiGravity CLI справді запущено один раз у plan mode, одне завдання без tools: формула/класифікація контрасту. `SUCCESS`, непорожня відповідь, 1 turn. Його загальне спрощення про множення parent opacity не використано як доказ групової композиції; складні випадки виключені з автоматичного PASS. Виміри з UI обчислено окремо.
- Один scoped Impeccable detector scan: exit 1, 7 `overused-font` та 2 `repeating-stripes-gradient` advisories. Це не 9 продуктових дефектів: шрифт уже обраний власником, штрихування передає missing data. Немає дозволу замінити Geist або приховати невідомі інтервали. Detector output збережено, clean-scan PASS не заявляється.

Виходи: `claude-requirements.json`, `antigravity-contrast.json`, `impeccable-detect.json` у каталозі доказів. Другим агентам не доручали повторний аудит, реалізацію або browser-прохід.

**Наступний крок — один окремо дозволений пакет максимум із трьох виправлень:**

1. **WQA-01:** контраст активної основної Field-дії.
2. **WQA-06:** 144 px flex-basis у column-кнопках Home-пікерів.
3. **WQA-02:** false dirty/budget reason від зміни лише Weather presentation на початковому/legacy example plan.

WQA-03/04/05 залишаються повним списком інших знахідок цього звіту; це не автоматичне доручення все переробляти. Після дозволених корекцій потрібна цільова перевірка змінених критеріїв і їхніх реальних залежностей, а не новий загальний аудит. До цього кандидат не позначено прийнятим і не перенесено у Flutter.

Цей запуск закінчується звітом. Код web/Flutter, токени, залежності, конфігурація, roadmap і CI не змінювалися; commit/push, новий дизайн та native-міграція не виконувалися.
