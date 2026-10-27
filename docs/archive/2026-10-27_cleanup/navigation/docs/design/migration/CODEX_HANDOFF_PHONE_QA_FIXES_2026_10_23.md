> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/migration/CODEX_HANDOFF_PHONE_QA_FIXES_2026_10_23.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../../docs/design/migration/CODEX_HANDOFF_PHONE_QA_FIXES_2026_10_23.md) · [Navigation index](../../../../NAVIGATION.md). Original SHA-256: `baec2e5aa7fe6da27a6b889428059c1fb158f973e20d5eb7dfc1fea778cad4a0`.

# Culmina — продовження виправлень після phone QA (передача контексту, 2026-10-23)

Ти продовжуєш роботу іншого агента. Попередні чати не потрібні: усе потрібне — у цьому файлі та в документах, на які він посилається. Перевіряй факти з цього файлу за кодом і git, перш ніж на них спиратися.

## 1. Обсяг цього запуску

Реалізуй **P-4, P-5 і P-6** з `docs/design/migration/PHONE_QA_FIX_PLAN_2026_10_23.md` — по одному, у цьому порядку, кожен зі своїми тестами. P-1, P-2 і P-3 уже реалізовані; повторно їх не роби.

**Не роби без окремого доручення власника:**
- commit, push, merge, rebase, stash, reset, checkout чужих гілок;
- QA-03, QA-10, а також будь-що поза P-4…P-6;
- будь-які дії з фізичним телефоном.

Після кожної задачі коротко звітуй і переходь до наступної. Після P-6 зупинись і подай підсумок (див. §7).

## 2. Де лежить робота

| Що | Значення |
| --- | --- |
| Робоча копія | git worktree `C:\Users\zalub\AppData\Local\Temp\culqa` (короткий шлях навмисно: довгі шляхи OneDrive ламають збірку) |
| Гілка | `fix/qa-02-save-status`, створена від `origin/develop` = `35992c93c6c4e43385694d101e2a9cfea406898d`; **нічого не закомічено** |
| Основне дерево власника | `C:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner`, гілка `develop` на `01b8049` із **відкладеними незакоміченими правками власника** (`equipment_editor.dart`, `target_selection_screen.dart` і два їхні тести). Не чіпай, не відкидай, не комітити їх. Там лише скопійовані документи QA |
| Еталон дизайну | `design/home-lab/` на `86873ce343160c860706091e12b257090cc96d94` (прийнятий власником); тільки читати |
| Інструменти | Flutter 3.47.4 / Dart 3.13.3 у `C:\flutter\bin`; `adb` у `%LOCALAPPDATA%\Android\Sdk\platform-tools` |

Зміни в робочому дереві, які **не можна включати в коміт**: файли `linux/…/generated_plugin_registrant*`, `generated_plugins.cmake`, `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/…`. Там лише інші закінчення рядків після `pub get`, вміст ідентичний.

## 3. Прочитай перед початком

1. `CLAUDE.md` — правила репозиторію; особливо Verification Policy V1–V8.
2. `docs/ENGINEERING_GUARDRAILS.md`: trap 12 (кольори лише через токени, у трьох палітрах; у Field лише червоний і чорний), trap 16 (memoization), trap 17 (доступність).
3. `docs/design/migration/PHONE_QA_2026_10_23.md` — звіт phone QA; QA-09 відкликано.
4. `docs/design/migration/PHONE_QA_FIX_PLAN_2026_10_23.md` — план; секції P-4…P-6 містять причину, зміну, тести й клас перевірки.
5. `docs/TECH_DEBT.md` — записи TD-114…TD-116 як зразок формату.

## 4. Що вже зроблено (не повторюй)

| Задача | Суть | Файли | Тести | Запис |
| --- | --- | --- | --- | --- |
| P-1 · QA-02 | Рядок над Save plan застарівав після першої правки збереженого плану. Додано `CurrentSession.onSessionChanged`: викликається після автозбереження, що змінило id, статус або ознаку «збережено»; ViewModel сповіщає слухачів і знімає колбек у `dispose` | `lib/domain/services/current_session.dart`, `lib/presentation/viewmodels/session_plan_viewmodel.dart` | `test/domain/services/current_session_state_test.dart`, `test/presentation/screens/home/plan_save_status_test.dart` | TD-114 |
| P-2 · QA-04 | Підпис основної (filled) кнопки змінено з 16/500 на 16/600, як `.primary-button` | `lib/core/theme/app_theme.dart`, `docs/DESIGN_SYSTEM.md` §6.1 | `test/core/theme/controls_theme_test.dart` (новий тест) | TD-115 |
| P-3 · QA-05 | Діалог «Unsaved changes» (план): кнопки в одному `Wrap`, вирівнювання праворуч, відступ 8 | `lib/presentation/shared/confirmation_patterns.dart` | `test/presentation/shared/unsaved_prompt_layout_test.dart` (з Geist) | TD-116 |

Докази на цьому стані:
- **Повний набір unit/widget-тестів (після P-2):** 2448 passed, 6 skipped, 0 failed.
- **Після P-3:** shared, Plan/Home, Tonight, Logbook і доступність — 313 passed.
- **Host E2E `core_loop_test`:** PASS (після P-1).
- **`flutter analyze --no-pub`:** чисто.

Індекс у `TECH_DEBT.md` зараз каже «34 open (or partly open) items». Наступний вільний номер — **TD-117**.

## 5. Що зробити

Деталі — у плані. Нижче коротко з перевіреними фактами.

**P-4 · QA-06 — вкладки Night/Moon/Weather.**
- **Файл:** `lib/presentation/screens/details/night_moon_screen.dart`, `TabBar` (близько рядка 112).
- **Що виправити:** `labelColor` і `unselectedLabelColor` не задані, тому неактивні вкладки мають основний колір.
- **Еталон (обчислений стиль):** активна вкладка 14 px / 600, `--text-primary`, лінія 2 px; неактивна 14 px / 400, `--text-secondary` (світла тема — rgb 90,89,85).
- **Зміна:** `labelColor: textPrimary`, `unselectedLabelColor: textSecondary`, вага активної — 600 (зараз 500).
- **Тести:** нова перевірка кольорів і ваги; `night_moon_browse_test`, `accessibility_test`. Вторинний червоний у Field нижче AA навмисно (ARCHITECTURE B16) — не «виправляй» це.

**P-5 · QA-07 — «Exact times & reading key».**
- **Файл:** `lib/presentation/widgets/night_browser_sections.dart`, функція `group` (близько рядка 454).
- **Що виправити:** рядки зараз `Row[Expanded(label), SizedBox(8), Flexible(Text(value, textAlign: right))]`, тому значення не доходять до правого краю, а значення Sun events починаються посередині рядка.
- **Еталон:** значення вирівняні по краю контенту (закінчуються на x = 356.4 з 375).
- **Зміна:** колонці значень дати tight fit (`Expanded`).
- **Тести:** геометрія — правий край значення дорівнює правому краю рядка, включно з дворядковим інтервалом «… to …»; `night_moon_browse_test`, `accessibility_test`.

**P-6 · QA-08 — вибрана година у Weather B.**
- **Файл:** `lib/presentation/widgets/weather_hybrid_view.dart`, вісь годин (близько рядків 780–810).
- **Що виправити:** зараз використовуються `hybrid.selection`, `textPrimary` і `hybrid.accent`.
- **Еталон** (`design/home-lab/weather-radix.css`, Hybrid blend, лише Light і Dark), кольори «фон / текст / лінія знизу»:
  - Light: `#c2e5ff / #113264 / #0d74ce`;
  - Dark: `#004074 / #c2e6ff / #70b8ff`;
  - Field під цей селектор не підпадає: лишаються `--selection`, `--text-primary` і лінія accent, тобто поточна поведінка.
- **Зміна:** три нові ролі в `HybridTokens` для всіх трьох палітр, без літералів у presentation.
- **Тести:** `weather_hybrid_view_test` (кольори вибраної комірки в кожній темі), `field_mode_darkness_test`, `presentation_style_rules_test`, `hybrid_tokens_test`, контраст.

## 6. Як перевіряти

- **Порядок для кожної задачі:** спершу тест, що падає з правильної причини, потім правка, потім регресії зачепленої області за V1. Ніколи не послаблюй тести; якщо змінюєш твердження, яке закріплювало стару поведінку, поясни це у звіті.
- **Для кожної задачі:** `dart format` змінених файлів, `flutter analyze --no-pub`, `dart run tool/check_encoding.dart`, `git diff --check`.
- **Повний набір** (`flutter test --no-pub`) — лише якщо зачеплену область не обмежити. P-6 змінює спільні токени, тому там його варто запустити й записати причину.
- **Документація в тій самій зміні:** рядок у `docs/TECH_DEBT.md` (індекс і деталі, формат як TD-114…116, «FIXED IN CODE …, not committed; the phone re-check is pending»), лічильник у індексі, статус «Status (date): implemented …» у секції відповідної P у плані. Копію плану поклади також в основне дерево (`…\Astro-Planner\docs\design\migration\`). Документи пиши англійською.

**Пастки цього середовища:**
- `tester.runAsync(() async => future)` чекає на future. Щоб збудувати кадр до завершення запису, запускай правку в блоці `{ … }` без `await`.
- Віджет-тест із `vm.selectSite` у планувальнику зависав на очікуванні погодних даних. Не повторюй цей підхід; перевіряй шлях на рівні сервісу.
- Seeding і запис у Drift у `testWidgets` — тільки всередині `runAsync`.
- Таймер `timeout` у bash або зупинка задачі вбиває тільки оболонку: `flutter_tester.exe` і `dart.exe` з `flutter test` лишаються висіти. Перед повторним запуском перевір процеси (`Get-CimInstance Win32_Process`) і зупиняй **лише свої**. Процеси Android Studio власника (`dart language-server --client-id=Android-Studio`, `tooling-daemon`, `devtools`, Flutter, запущений о 14:10) не чіпай.
- Для точної геометрії кнопок і тексту завантажуй Geist (`FontLoader`, як у `unsaved_prompt_layout_test.dart`), бо стандартний тестовий шрифт Ahem дає інші ширини.
- Обчислені стилі еталона знімай через `tool/design/hybrid_transfer/webcap.cjs` (Playwright 1.64.1 у `~/.codex/tools/culmina-playwright`; сервер — `python design/home-lab/scripts/serve_preview.py --port 4197`). Пам’ятай: курсор Playwright після кліку дає hover-стан на скриншоті (саме так виник хибний QA-09); кольори бери з обчислених стилів, а не з пікселів.

## 7. Телефон і дані — тільки з окремим дозволом

Phone QA вже виконано; у цьому запуску телефон не використовуй.

**Для майбутнього запуску з телефоном:**
- **Пристрій і застосунок:** `PRRGPZ8PZ5E6OJ7T`, Xiaomi 14T Pro, Android 16, 375.4 × 792 dp. Встановлено перевірочний release `io.github.buffur.culmina`, SHA-256 `fff2261d…24ebe`, debug-підпис.
- **Інцидент QA-01:** під час phone QA лаунчер HyperOS видалив пакет `io.github.buffur.culmina.dev` після фізичних дотиків. Власник ще не підтвердив, що це був він.
- **QA-03 не підтверджено:** після тапу «Don't allow» дозвіл геолокації записався як наданий. Не повторюй цей тап автоматично.
- **Ніколи:** `flutter drive` на телефоні, uninstall, `pm clear`.

## 8. Фінальний звіт

Для кожної з P-4…P-6 подай:
- змінені файли і суть правки;
- тест, який падав до правки, і зелений результат після неї;
- набори регресій із кількістю тестів;
- результати analyze, format і encoding;
- записи TD-117…;
- що не перевірено: телефон, нова release-збірка.

Окремо перелічи всі незакомічені файли гілки, щоб власник вирішив, як комітити: окремі коміти P-1…P-6 без змін у згенерованих registrant-файлах.
