# Evidence: update-appkit-and-mvpa

## Visual check of the confirm dialog (2026-10-22)

A temporary system test signed in as the admin, opened the user list, clicked `Delete` on a user row and took a screenshot of the open dialog at two widths. A person read the screenshots. The test file was deleted afterwards and is not in the branch.

- 1400px: a centred box over a dimmed page. The message reads "Are you sure you want to delete this user?". Below it, on the right, are a plain `Cancel` and a red `Delete`, in that order.
- 375px: the same box. The two buttons stack at full width, `Cancel` on top and a red `Delete` below.
- 375px user list, not part of this change: the table is cramped. The `Role` header breaks into two lines and the row `Delete` button wraps to "Del / ete". The plan defers mvpa.css stacking tables.

## Visual check of the other pages (2026-10-22)

The same temporary system test, deleted afterwards, took screenshots at 1400px and 375px as each role. A person read them.

- Sign-in after a failed attempt: the flash sits at the top right of the viewport, outside the sign-in card. At 375px it spans the top. The card and the filled `Sign in` button are intact.
- Admin, edit user: the form ends in an action row on the right, a plain `Cancel` then a filled `Update User`. At 375px the row stacks.
- Parent dashboard: `Give Sticker` is green, `Give Penalty` is red, and the nav `Logout` is red. The two buttons sit about 8px apart vertically. This comes from mvpa.css's "a form after a form gets space above" rule of 2026-09-04, which the old pin also had, so this change does not cause it.
- Parent, child settings: every form ends in a right-aligned `Save`. At 375px each `Save` is full width.
- Child dashboard: the card, the sticker grid and the nav render normally. The push-enable button is not on this page.

## Push button and Turn off (2026-10-22)

A temporary system test scrolled to each control at 1400px and 375px. A person read the screenshots.

- Push button ("Enable reminders") on the parent layout: it renders as a plain bordered button with a page-surface background, not a filled one. This is visible at 375px. At 1400px the fixed sidebar header covers it, and `elementFromPoint` at its centre returns the sidebar `HEADER`, so a parent cannot click it on desktop. The same probe on `origin/main` (old appkit and mvpa-css pins) returns the same, so the cover-up exists without this change. A follow-up can move the `<fieldset>` into `<main>`.
- Child settings, "Turn off": the red button sits under each allowance form, below its right-aligned `Save`, at 1400px. At 375px it is a red button at the left, below the full-width `Save`.

## Automated checks

`bin/rails test` and `bin/rails test:system` pass. The system tests cover confirm, Cancel, Escape and a second confirm in one page session, and the browser-confirm fallback on the sign-in page.
