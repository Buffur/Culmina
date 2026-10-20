# Перевірка коригувального пакета Hybrid (`20261020-hybrid7`)

**Підсумок: результат прийнятний як браузерне доопрацювання.** Усі чотири P2, витік палітри в галереї та проміжок у Welcome закрито. Два другорядні пункти не блокують приймання: фокус на «Apply checked values» не доведено, а одна позначка «відповідає поточним файлам» у зведеному звіті застаріла. Оцінку 30/40 не перераховую, вона лишається судженням до корекції.

Я лише читав файли, нічого не запускав і не змінював. Усі дані про взаємодію з інтерфейсом взято з прогонів батьківського агента.

## Що я переглянув сам

**PNG — усі 8 зазначених файлів:**
- `corrections/screenshots/`: `home-360-light-2-bottom`, `library-360-field-2-bottom`, `gallery-blend-light-dusk-100`, `library-photo-save-blocked-200`, `library-json-save-blocked-200`, `library-rig-sources-200`;
- `targeted-metadata/screenshots/metadata-plan-review`;
- `after-plan-gain`.

Жоден шлях не був недоступним.

**Код:**
- повністю: `hybrid-refinement.css` (52 рядки) і `hybrid-ui.js` (19 рядків);
- `library.js`, рядки 592–613, 982–1051, 1100–1124, 1360–1389;
- `app.js`, рядки 20–64, 146–159, 225–244 (Welcome — рядок 236).

**Докази:**
- повністю: `CLAUDE_QA.md`, `SCREENSHOT_MANIFEST.md`, `BROWSER_QA_FINAL.md`, `library/checks.json`, `source-hashes.json`, `implementation.diff` (998 рядків);
- `corrections/browser-checks.json`: рядки 1–1385, 1900–3199, 5380–5517. Пропущено 1386–1899 (решта випадків навігації на 360 px) і 3200–5379 (рядки матриці та знімків); результат за ними беру з підсумку файлу: 51/51;
- `browser-final-checks.json`: рядки 1–80 і 29130–29264;
- `targeted/browser-checks.json`: рядки 5940–5979;
- `targeted-metadata/browser-checks.json`: рядки 1–200 і 230–312.

**Хеші.** `source-hashes.json` побайтово збігається з `sourceAfter` коригувального прогону, і `sourceStable` = true. Від `finalSourceHashes` він відрізняється лише чотирма файлами корекції: `app.js`, `hybrid-refinement.css`, `hybrid-ui.js`, `library.js`. Хеш `plan.js` (`6538…`) і решти 26 файлів не змінився, тому незачеплені критерії можна брати з попередніх прогонів. Самі хеші я не перераховував, бо оболонки не мав. Зміст прочитаних файлів збігається з боком «after» у diff.

## Висновки по кожній знахідці

| Пункт | Статус | Підстава |
|---|---|---|
| **P2-1** навігація при 200% | **PASS** | **Мій перегляд:** обидва PNG показують сітку 2×2 і цілі слова: «Tonight», «Logbook», «Library», «Settings». Кільце фокуса на Tonight видно, поточний розділ має окреме тло. CSS (рядки 43–49) робить дві колонки лише за `data-text-scale="2"` і забороняє переноси. **Повторно використані дані з браузера:** 24 випадки (412 і 360 px; світла, темна й польова теми; Home, Logbook, Library, Settings). Скрізь шрифт 22px, `lines: 1`, `nowrap`, кнопки 56 px заввишки і 145–200 px завширшки, два ряди. Фокус — суцільна обвідка 2px, reduced motion усе вимикає. При 100% зберігаються 4 колонки, 11px, `column` (4 випадки, ширина 412). Мій скриншот галереї при 100% теж показує 4 колонки. Сам метод підрахунку рядків через Range-прямокутники видно лише як готове поле `lines`; це твердження батьківського агента. |
| **P2-2** Save при незастосованому огляді | **PASS** (з одним NOT VERIFIED) | **Код:** перевірка в `save()` (`library.js:1368-1375`) стоїть до `validateRig()` і до будь-якого запису. Вона спрацьовує і на фото-огляд, і на JSON-огляд, і на файл, що ще читається. Після Apply поле `metadata` обнуляється (`:1114`), тож наступний Save проходить. Cancel не переносить значення в чернетку. Тексти правдиві й називають обидва кроки: «Select fields, choose Apply checked values, then Save rig» (`:994`, `:1016`). Старого «Save rig records them» більше немає. **Мій перегляд:** на обох PNG при 200% видно червоне локальне повідомлення «…Nothing has been saved.». **Повторно використані дані:** у коригувальному прогоні для фото й JSON `pendingSaveBlocked` = true і `cancelThenSaveKeepsOriginalDraft` = true. Сценарій «Apply, потім Save записує позначені значення» є лише в `library/checks.json`, а там немає ні хешів, ні часу прогону. **NOT VERIFIED:** що фокус справді переходить на Apply. JSON не фіксує активний елемент, а на PNG кільця фокуса не видно. Код лише просить `rerenderKeeping('[data-metadata-apply]')`; визначення цієї функції я не читав. |
| **P2-3** Sources and preview limits | **PASS** | `library.js:599` для Hybrid: «From a photo demonstrates the review with labelled sample values; image bytes are not parsed. Import rig values from JSON is a separate local file-reading workflow. Manual entry remains available.» Фраза «a rig is entered by hand here» лишилася тільки для варіантів, крім Hybrid. Повний текст підтверджено в `rootText`. Мій PNG показує лише початок розкритого блоку. Про резервні копії (backup) цей текст не говорить. |
| **P2-4** diff, хеші, ретести | **PASS** (з приміткою) | Diff містить усе потрібне: `clearPhotoSource` і очищення `metadataSource` під час ручного редагування та зміни типу кадру (diff:791, 823, 842); Welcome (diff:77); область видимості в `hybrid-ui.js` (diff:286); навігацію при 200% (diff:269–275); перевірку Save і новий текст (diff:356, 392, 518). Ретести на тих самих вхідних файлах є: `targeted/` (33/34) → `targeted-metadata/` (1/1; draft, editor checkpoint, outer Apply, Save) → `corrections/` (51/51). Усі 9 провалів явно замінено в `browser-final-checks.json`. Примітка — нижче, пункт 2. |
| Витік палітри в галереї | **PASS** | `hybrid-ui.js:5` ставить `data-variant` на корінь лише для `body.planner-page`. За diff, у `index.html` тег `<body>` без класу, а `workspace.html`, `plan.html` і `conditions.html` мають `planner-page`. Нові змінні неба в `night.css` обмежені `:root[data-variant=blend]` і `.variant-blend`. **Повторно використані дані:** 9 комбінацій (3 теми × 3 палітри). Скрізь лише blend має нові значення, а Manuscript, Soft і Desk однакові між собою й зі старими значеннями окремої сторінки Paper. Рядки навігації Workspace при 200% підтверджують, що окремі сторінки й далі отримують `data-variant` на корені. Змін у нативному застосунку немає. |
| Welcome | **PASS** | `app.js:236`: ті самі дві кнопки з тими самими `data-action` для blend загорнуті в наявний `.dialog-actions`. **Повторно використані дані:** `rowGap`/`columnGap` = 12px при 100% і 200%, без переповнення й без замалих цілей. PNG Welcome не входив до мого списку. |

## Що лишилося

Нові P1 чи P2 не знайдено. Усе нижче — P3 і приймання не блокує.

1. **Кнопка Apply частково схована під закріпленою панеллю Save/Cancel при 200%.** Це видно на обох PNG із заблокованим збереженням: на кнопці читається лише «Apply checked». Виклик `scrollIntoView({block:'nearest'})` (`:1373`) не враховує закріплений низ екрана. Разом із недоведеним фокусом це варто виправити, але сама цілісність даних уже захищена.
2. **Зведений звіт частково застарів.** `BROWSER_QA_FINAL.md:11` («Final source hashes match current files: True») і `currentSourcesMatchFinalProof: true` у `browser-final-checks.json` стосуються стану до корекції: `app.js 58cd…`, `hybrid-ui.js c80c…`, `hybrid-refinement.css 44f7…`, `library.js 5208…`. Цей звіт не включає `corrections/browser-checks.json`. Тому чинними вхідними даними слід вважати `source-hashes.json`, коригувальний прогін і diff.
3. **`library/checks.json` не прив'язаний до хешів.** Тому сценарій «Apply, потім Save» для фото доведено кодом і словами батьківського агента, а не прогоном на зафіксованих файлах.
4. **Селектор `html[data-variant="blend"] .phone-detail`** (CSS:3) у галереї більше не спрацьовує. Діалог Welcome втратив лише колір каретки й смуги прокрутки; на приймання це не впливає.

## Обмеження, що лишаються

- Оригінальних референсних зображень (2)–(10) досі немає.
- Сторінки Plan, Night, Moon і Weather після корекції повторно не перевірялися. Їхні файли не змінилися, тому результати взято з попередніх прогонів. Чи мають ці екрани нижню навігацію при 200%, я не перевіряв.
- Масштаб 125% не входив до знахідки й не перевірявся.
- Не перевірено нативний Android, TalkBack, IME і кнопку Back, справжнє читання метаданих, а також наукову точність астрономії й погоди.
- Як і раніше, деякі P3 видно на скриншотах, але до цієї корекції вони не належать. Наприклад, «Saved in this browser.» поруч з активною кнопкою «Save plan» на `after-plan-gain.png`.

Ця корекція не обіцяє підвищення оцінки.