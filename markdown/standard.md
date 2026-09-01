# Источники стандартов для markdown-промптов

Справочник к четырём промптам в этой папке. Нужен, чтобы быстро
перепроверить любое правило и пересобрать промпты, если платформа
изменит поведение.

Промпты и их варианты:

| Файл | Вариант |
| --- | --- |
| `prompt_universal_markdown.txt` | A — универсальный (CommonMark) |
| `prompt_convert_to_universal_markdown.txt` | A — универсальный (CommonMark) |
| `prompt_gfm_github.txt` | B — GFM / только GitHub |
| `prompt_convert_to_gfm_github.txt` | B — GFM / только GitHub |

Все ссылки проверены 2026-09-01: отдают HTTP 200. Два адреса
заменены на канонические после редиректа (GitLab, Obsidian).
Утверждения из раздела «Проверено эмпирически» прогнаны через
GitHub Markdown API в ту же дату.

## Вариант A — универсальный (CommonMark)

Целевые рендереры: GitHub, GitLab, PyCharm, VS Code, Obsidian,
импорт в Notion.

### Первоисточники варианта A

| Что | Ссылка |
| --- | --- |
| CommonMark Spec 0.31.2 — базовый синтаксис | https://spec.commonmark.org/0.31.2/ |
| Живая песочница спецификации (проверить конкретный кусок) | https://spec.commonmark.org/dingus/ |
| Список версий спецификации | https://spec.commonmark.org/ |
| Исходный Markdown Грубера — поведение legacy-парсеров | https://daringfireball.net/projects/markdown/syntax |
| GFM Spec — для трёх разрешённых расширений | https://github.github.com/gfm/ |

### Рендереры, чьё поведение ограничивает вариант A

| Рендерер | Что проверять | Ссылка |
| --- | --- | --- |
| GitLab | якоря заголовков, набор расширений | https://docs.gitlab.com/user/markdown/ |
| VS Code | движок markdown-it, режим CommonMark | https://code.visualstudio.com/docs/languages/markdown |
| markdown-it (движок VS Code) | соответствие CommonMark | https://github.com/markdown-it/markdown-it |
| PyCharm / JetBrains | поддерживаемые расширения в превью | https://www.jetbrains.com/help/pycharm/markdown.html |
| Obsidian | якоря по исходному тексту заголовка | https://obsidian.md/help/Linking+notes+and+files/Internal+links |
| Notion | вырезание HTML и потеря якорей при импорте | https://www.notion.com/help/import-data-into-notion |

### Правило промпта варианта A — где проверять

| Правило в промпте | Источник |
| --- | --- |
| Заголовки ATX; setext валиден, но не используем | CommonMark Spec, разделы ATX headings и Setext headings |
| Таблицы, зачёркивание, чекбоксы — единственные расширения | GFM Spec, разделы Tables, Strikethrough, Task list items |
| Выравнивание `---` / `:---` / `:---:` / `---:` | GFM Spec, раздел Tables |
| Вложенные списки — 4 пробела | CommonMark Spec, раздел List items + синтаксис Грубера (legacy требует 4 пробела или таб) |
| Два пробела как жёсткий перенос ненадёжны | CommonMark Spec, раздел Hard line breaks |
| Сноски `[^1]` не использовать | В CommonMark Spec их нет вообще; в GFM Spec их тоже нет — только docs.github.com |
| `{#id}` не использовать | Синтаксис Pandoc/kramdown, вне CommonMark и GFM |
| `<a id="...">`, `<br>`, `<details>` и прочий разрешённый HTML | CommonMark Spec, разделы HTML blocks и Raw HTML; ограничения — Notion (вырезает) и GitHub (префикс `user-content-` у `id`) |
| Якоря по алгоритму GitHub | Алгоритм официально не специфицирован, см. раздел «Не покрыто спецификациями и не проверяется через API» |
| Ответ в блоке из четырёх бэктиков | CommonMark Spec, раздел Fenced code blocks: закрывающий забор не короче открывающего, поэтому внешний забор должен быть длиннее любого внутреннего |

## Вариант B — GFM / только GitHub

Целевые контексты: README, PR, issue, wiki на github.com.

### Первоисточники варианта B

| Что | Ссылка |
| --- | --- |
| GFM Spec 0.29-gfm — таблицы, чекбоксы, зачёркивание, автоссылки на URL | https://github.github.com/gfm/ |
| Базовый синтаксис на GitHub | https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax |
| Alert-блоки NOTE/TIP/IMPORTANT/WARNING/CAUTION | https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts |
| Диаграммы Mermaid | https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams |
| Таблицы | https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-tables |
| Ссылки на issues/PR `#123`, `GH-123`, упоминания | https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls |
| Сворачиваемые блоки, HTML-возможности | https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting |
| Сноски `[^1]` | https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#footnotes |
| Набор emoji-кодов (`:warning:` и т.п.) | https://github.com/github/gemoji |
| Бейджи | https://shields.io/ |

### Правило промпта варианта B — где проверять

| Правило в промпте | Источник |
| --- | --- |
| Таблицы и выравнивание | GFM Spec, раздел Tables |
| Чекбоксы `- [ ]` / `- [x]` | GFM Spec, раздел Task list items |
| Зачёркивание `~~текст~~` | GFM Spec, раздел Strikethrough |
| Голые URL становятся ссылками | GFM Spec, раздел Autolinks (extension) |
| Ссылки на issues/PR `#123`, `GH-123`, `@username` | docs.github.com, Autolinked references — в GFM Spec ИХ НЕТ, это поведение github.com, а не диалекта |
| Alert-блоки | docs.github.com, Basic writing, якорь `#alerts` — в GFM Spec ИХ НЕТ |
| Диаграммы Mermaid | docs.github.com, Creating diagrams — в GFM Spec ЕГО НЕТ |
| Сноски `[^1]` | docs.github.com, якорь `#footnotes` — в GFM Spec ИХ НЕТ |
| Emoji-коды | github/gemoji — в GFM Spec ИХ НЕТ |
| Два пробела как жёсткий перенос ненадёжны | CommonMark Spec, раздел Hard line breaks (GFM наследует) |
| `{#custom-id}` не поддерживается | Проверено: GitHub выводит `{#custom-id}` как обычный текст внутри заголовка, см. раздел «Проверено эмпирически» |
| Санитизация HTML, разрешённые теги | Реализация, см. раздел «Не покрыто спецификациями и не проверяется через API» |
| HTML-таблицы с rowspan/colspan остаются HTML | GFM Spec, раздел Tables — блочное содержимое и объединения ячеек в синтаксисе не предусмотрены |
| Ответ в блоке из четырёх бэктиков | GFM Spec наследует CommonMark, раздел Fenced code blocks |

## Проверено эмпирически

Прогнано через GitHub Markdown API 2026-09-01. Утверждения ниже —
наблюдаемое поведение, а не выдержка из спецификации, но проверены
на реальном рендерере.

| Утверждение | Результат |
| --- | --- |
| `{#custom-id}` не поддерживается | Подтверждено: `## Заголовок {#custom-id}` даёт `<h2>Заголовок {#custom-id}</h2>` — синтаксис остаётся видимым текстом |
| Пользовательский `id` получает префикс | Подтверждено: `<a id="my-anchor"></a>` рендерится как `id="user-content-my-anchor"` |
| Emoji-коды разворачиваются в символ | Подтверждено: `:rocket:` в заголовке отдаётся как 🚀 |
| Alert-блоки: документированы все пять типов | Подтверждено: на странице Basic writing есть якорь `#alerts` и примеры NOTE, TIP, IMPORTANT, WARNING, CAUTION |
| Сноски документированы | Подтверждено: якорь `#footnotes` на той же странице |
| `GH-123` — рабочая форма ссылки на issue | Подтверждено: пример `GH-26` на странице Autolinked references |

Команда для повторной проверки (PowerShell 7, авторизация не нужна,
действует общий лимит запросов):

```powershell
$body = @{ text = (Get-Content -Raw ./test.md); mode = 'gfm' } | ConvertTo-Json -Compress
Invoke-RestMethod -Method Post -Uri 'https://api.github.com/markdown' -Body $body -ContentType 'application/json'
```

## Не покрыто спецификациями и не проверяется через API

Markdown API возвращает заголовки БЕЗ атрибута `id` — голый `<h2>`.
Якоря добавляет фронтенд github.com, а не конвейер рендеринга,
поэтому через API алгоритм якорей проверить нельзя. Только реальная
страница: залить тестовый файл в gist или репозиторий и посмотреть
`href` у значка ссылки рядом с заголовком.

| Пункт | Чем проверять |
| --- | --- |
| Алгоритм генерации якорей: нижний регистр, пробелы заменены на дефисы, пунктуация убрана, дефисы и подчёркивания сохранены, юникод сохранён, эмодзи вырезаны | Официального описания нет. Тестовый файл в gist, смотреть `href` якорей |
| Суффиксы `-1`, `-2` у одинаковых заголовков | Так же, файл с дублирующимися заголовками |
| Конкретный whitelist тегов и атрибутов санитайзера | Внутренний конвейер GitHub закрыт, полного официального списка нет. Ориентиры: https://github.com/gjtorikian/html-pipeline и https://github.com/github/markup, точечно — через Markdown API |
| Рендерятся ли alert-блоки и mermaid в wiki, а не только в README/issue/PR | Только эмпирически, на тестовой странице wiki: wiki рендерится отдельным путём |
| Поведение Notion при импорте (HTML, якоря) | Только эмпирически: импортировать тестовый файл |
| Расхождения якорей GitLab и GitHub | https://docs.gitlab.com/user/markdown/ + один тестовый файл в обеих системах |

## Решения без источника

Под эти пункты спецификации нет и искать её не нужно — это
выбранная политика, а не факт о формате. Меняются волевым решением.

| Правило | Зачем введено |
| --- | --- |
| Не выдумывать `#123`, `GH-123`, `@username`, бейджи | Выдуманный номер станет рабочей ссылкой на чужой существующий issue, выдуманный логин — на чужого пользователя |
| ASCII-арт не переписывать в mermaid по умолчанию | Восстановление связей по картинке — домысливание, а не смена разметки; конфликтует с требованием «без потерь» |
| Setext-заголовки не использовать, хотя они валидны | Единый ATX-стиль читаемее и не путается с горизонтальной линией `---` |
| Вложенные списки 4 пробела, а не 2 | 2 корректны по CommonMark, 4 работают и в CommonMark, и в legacy-парсерах — выбран более широкий охват |
| Пояснения только после блока кода | Чтобы результат конвертации копировался целиком, без вычистки комментариев |

## Как пересобрать промпты

1. Открыть источник, соответствующий изменившемуся правилу, по
   таблицам выше.
2. Если правило из раздела «Не покрыто спецификациями и не
   проверяется через API» — сначала
   прогнать проверку на реальной странице, потом править. Если оно
   из раздела «Проверено эмпирически» — повторить запрос к Markdown
   API командой оттуда.
3. Если правило из раздела «Решения без источника» — спецификацию
   не искать, решать по задаче.
4. Правку внести в ОБА файла варианта (генерация и конвертация),
   иначе пара разъедется — это уже случалось с политикой по HTML.
5. Сверить, что правило не противоречит соседнему варианту: вариант
   A не должен разрешать то, что вырезает Notion, вариант B не
   должен запрещать то, что GitHub рендерит.
