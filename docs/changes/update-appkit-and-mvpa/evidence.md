# Evidence: update-appkit-and-mvpa

## Visual check of the confirm dialog (2026-10-22)

A temporary system test signed in as the admin, opened the user list, clicked `Delete` on a user row and took a screenshot of the open dialog at two widths. A person read the screenshots. The test file was deleted afterwards and is not in the branch.

- 1400px: a centred box over a dimmed page. The message reads "Are you sure you want to delete this user?". Below it, on the right, are a plain `Cancel` and a red `Delete`, in that order.
- 375px: the same box. The two buttons stack at full width, `Cancel` on top and a red `Delete` below.
- 375px user list, not part of this change: the table is cramped. The `Role` header breaks into two lines and the row `Delete` button wraps to "Del / ete". The plan defers mvpa.css stacking tables.

## Automated checks

`bin/rails test` and `bin/rails test:system` pass. The system tests cover confirm, Cancel, Escape and a second confirm in one page session, and the browser-confirm fallback on the sign-in page.
