# Intent: Align views with journal_administration patterns

Author: Etienne van Delden. Status: accepted (2026-11-06). Type: refactor. Delivery: autonomous. Codex review: no.

## Problem

The views in sticker-app do not share one page structure. Each page writes its own `<header><h1>` and picks its own wrapper (`<section>`, `<div>` or `<main>`).

The child edit page holds six `<article>` blocks with a form each and no heading, so a parent cannot tell the name, avatar, goal, Zakgeld and Kleedgeld forms apart.

The error `<aside>` is pasted six times on that page and again in the admin user form. Forms have no shared footer: Submit and Cancel sit in loose `<nav>` blocks in a different order per form.

The sibling app `~/Developer/journal_administration` solves all of this with shared partials and semantic markup. A parent or admin who uses both apps sees two different structures.

## Proposed outcome

Every page of sticker-app follows the journal pattern. One title bar partial renders the `<h1>` and the page links. Each block of content is a `<section>` that starts with its own `<h2>`. Forms share one error partial and one action row. Read-only data uses `<dl>`. Tables carry a heading id and `aria-labelledby`. Sticker cells are list items.

The compact parent dashboard still fits three children above the tab bar on a 375 CSS px wide phone.

## Affected users and systems

- Parents, children and admins, who see new headings and a consistent layout.
- Screen reader users, who get a heading and a labelled table per block.
- Views under `app/views/parent`, `child`, `admin`, `users` and `layouts/parent`, plus the stylesheets in `app/assets/stylesheets`.
- Locale files `config/locales/en.yml`, `nl.yml` and `it.yml`, for the new headings.

## Constraints

- No new dependencies, no migrations, no deploy files, no system tooling. Autonomous delivery needs no permission beyond these.
- Views owned by the `Appkit::Engine` gem (login, preferences, the nav partial) stay as they are.
- `test/system/parent_dashboard_fit_test.rb` stays green without edits to its thresholds. Three children, long names and Dutch labels must still fit.
- Locale files stay normalized (`bundle exec ruby ./bin/check_i18n_normalized`). Every new key exists in `en`, `nl` and `it`.
- No linter disable comments. ERB lint, herb lint and Rubocop stay green.
- The markup follows the mvpa.css changelog for the locked revision `06778c8`. mvpa styles `main > header`, `main > header nav`, `main > header h1`, a `<footer>` that is the last child of a form, and stacking tables. The markup must match those selectors.
- No local copy of journal's `title_bar.css`. mvpa already gives `main > header h1` `min-inline-size: 0` and `overflow-wrap: anywhere` (changelog 2026-10-25, upgrade step 6).
- Keep `[data-mvpa-flashes]` outside `<main>` (changelog 2026-10-19, upgrade step 9). The parent layout already renders flashes before `<main>`.
- `main` is a size container. A child that relied on `main` growing with its content now overflows, so the plan checks the wide pages. The confetti container is appended to `<body>`, so it is not affected.

## In scope

1. `shared/_title_bar` partial, copied from journal (the partial only, no CSS), used by every page. The `<header>` is a direct child of `<main>`, because mvpa styles `main > header`. The loose back, history and settings links move into its `<nav>`.
2. An `<h2>` as the first child of each `<section>` on the child edit page: name, avatar, goals, Zakgeld, Kleedgeld. Each `<article>` that holds one form becomes a `<section>` inside one `<article>`.
3. `shared/_form_errors` partial, with an `<h2>`, replacing every pasted error `<aside>`.
4. `shared/_action_row` partial: a `<footer>` as the last child of the form, buttons in the order Delete, Cancel, Save (changelog 2026-10-13). Cancel is a link with `role="button"` and `class="button-secondary"`, so it reads as plain next to the filled Save. "Turn off allowance" is a button in that footer that submits a separate DELETE form through the `form` attribute, as journal does; a DELETE form's button is red by default.
5. `<dl>` for read-only data: the allowance summary on the parent card and the child dashboard, which share one `_allowances` partial.
6. The stacking-table markup from changelog 2026-10-19, on `admin/users/index`: `data-stack`, `role="table"`, `role="rowgroup"` on `thead` and `tbody`, `role="row"`, `role="columnheader"`, `role="cell"`, a `data-label` on every `td`, a heading id with `aria-labelledby`, and `<time datetime>` for dates. No `overflow-x` wrapper.
7. Sticker cells on the child card become a `<ul>` of `<li>`, with the existing classes.
8. The push-subscribe button moves from the loose `<fieldset>` after `<main>` into a `<section>` with an `<h2>` at the end of `<main>` in `layouts/parent`.
9. `dashboard_row.css` is kept. Its selectors change only where the title bar partial changes the markup they match.

## Out of scope

- Colours, fonts, theme tokens and any new CSS design.
- Behaviour, routes, controllers, models and Stimulus controllers.
- The `Appkit::Engine` views and the nav partial.
- Moving the push button to another page.
- New features on the allowance pages.

## Acceptance criteria

- Every page has one `<h1>`, rendered inside a `<header>` that is a direct child of `<main>`, with its links in a `<nav>` in that header. The page no longer wraps that header in a `<section>` or `<div>`.
- On the child edit page a parent sees five headings, one above each form: name, avatar, goals, Zakgeld, Kleedgeld. Each heading is the first child of its `<section>`.
- A form with errors shows one alert `<aside>` with an `<h2>` that counts the errors, on every form that has one.
- Every form ends in a `<footer>` as its last child, with Cancel and Save. The "turn off allowance" button sits in the same footer, first, and is red.
- Cancel never looks like the default action: it is plain, and Save is filled.
- The allowance summary on the parent card and on the child dashboard comes from the same partial and reads as `<dl>` terms and details.
- The admin user table has a heading id, and its `<table>` points at it with `aria-labelledby`. At phone width each row stacks and each cell shows its label.
- A `<data>` element never sits inside a link, because mvpa draws it as a count badge there.
- The child card lists each sticker as an `<li>` in a `<ul>`. Empty slots still show ⭐.
- The push button is inside `<main>`, in a `<section>` with an `<h2>`, on every parent page.
- Three children, each with a card ready, still fit above the tab bar on an iPhone 12 mini (`parent_dashboard_fit_test`).
- The new headings read in English, Dutch and Italian.

## Flagged concerns

- The journal title bar and the three-children fit conflict. Once the parent dashboard `<header>` is a direct child of `<main>`, mvpa styles it as a page header, and the Settings link becomes a bordered 44px button in the title bar. That adds height above the three rows. `dashboard_row.css` also matches the old `main > section:has(> article…) > header h1` shape. The fit wins: `parent_dashboard_fit_test` stays green, and the plan moves or restyles the title-bar link on that one page if the rows no longer fit.

## Decisions

- One intent for all nine items — the items share the same partials and CSS, so splitting adds rebase work.
- A heading is the first child inside its `<section>`, not a sibling above it — matches the journal pattern, confirmed by Etienne ("yes, that is what i meant").
- All nine items are in scope — Etienne: "I want all items".
- The push button stays on every parent page, inside a `<section>` rendered by the layout — no behaviour change.
- Autonomous delivery, without the Codex review — the change is markup only and the system tests cover the layout.
- Headings default to the labels already on the page: name, avatar, goals, Zakgeld and Kleedgeld (Kleedgeld and Zakgeld keep their Dutch terms in every locale) — chosen by Claude as a default, not asked.

## Open questions

None.
