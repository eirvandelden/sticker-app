# Intent: Parent dashboard fits three children on an iPhone 12 mini

Author: Etienne van Delden de la Haije. Status: accepted (2026-11-04). Type: bugfix. Delivery: autonomous. Codex review: no.

## Problem

A parent who opens Sticker App from the home screen of an iPhone 12 mini cannot see all three children at once. Each child row is about 230 CSS px tall, so only about two rows fit above the bottom tab bar. The parent must scroll to reach the third child's Give sticker and Give penalty buttons. A parent also cannot mark a finished card as given from the dashboard: the dashboard only says "1 card ready to reward!", and the button lives on the child's own page.

The bottom tab bar is broken on phones. Logout is a red button, not a tab: it sits lower than the other tabs and runs off the right edge. Nothing keeps the bar clear of the iPhone home indicator.

Commit `0ce3339` (2026-09-16) already set the goal "all three children and their main actions fit on a phone screen without scrolling". That goal is not met.

## Proposed outcome

The parent opens the home-screen app and sees three children, each with Give sticker and Give penalty. A child with a card ready to reward also shows Mark card given in their row. Nothing needs scrolling. The tab bar shows only whole, aligned tabs, clear of the home indicator. Logout moves from the tab bar to the Preferences page.

## Affected users and systems

- Parents on the parent dashboard (`/parent/children`), on phones down to the iPhone 12 mini.
- The live updates of the dashboard row over Action Cable: the row must stay correct when a sticker completes a card or a reward is given.
- Admins, who use the same parent layout and get extra tabs (Overview, Users).
- Children: the child layout shares the tab bar, so children also log out from Preferences.

## Constraints

- Smallest supported device: iPhone 12 mini, 375×812 CSS px, opened as a home-screen app (standalone).
- The bottom tab bar and base styles come from the `mvpa.css` and `appkit` gems. This app can override them, but it does not change the gems.
- No new dependencies. No migrations, system tools or deploy files are expected. Any of these becomes a stop-and-ask.

## In scope

- The parent dashboard rows at phone width.
- Mark card given in a child's dashboard row, only when that child has a card ready to reward.
- The bottom tab bar in the parent and child layouts: whole, aligned tabs, clear of the home indicator.
- Logout moves from the tab bar to the Preferences page, for parents, admins and children.

## Out of scope

- The child's own dashboard, apart from its tab bar.
- More than three children: a fourth child may need scrolling.
- The parent's child page, history page and settings page.
- Allowances.
- Undo, a note or an emoji choice when giving a sticker.

## Acceptance criteria

- Three children, none with a card ready: on a 375×812 home-screen app, the parent sees all three names, their progress, and Give sticker and Give penalty for each, without scrolling.
- Three children, each with a card ready: the parent also sees Mark card given for each, and all three rows still fit without scrolling.
- Charlie has a card ready and Bob has none: Charlie's row shows Mark card given, Bob's row does not.
- The parent taps Mark card given for Charlie: Charlie's oldest ready card is marked given. The button disappears when Charlie has no ready card left.
- A parent has a child with two cards ready: one tap marks the oldest one given, and the button stays until the second one is given too.
- Bob's card completes while the dashboard is open: Mark card given appears in Bob's row without a reload, and the three rows still fit.
- On the iPhone 12 mini home-screen app, every tab in the bar is whole, in one aligned row, and above the home indicator. This holds for a parent, an admin (with Overview and Users) and a child.
- The tab bar has no Logout. The parent opens Preferences, taps Log out, and lands on the sign-in page.

## Decisions

- Design for the home-screen app, not the Safari tab — no reason given.
- Show Mark card given only when a card is ready — no reason given.
- Record it as a bugfix — the September change promised this fit and did not deliver it.
- Fix the tab bar in this change, though Claude proposed a split — no reason given.
- Move Logout to Preferences — no reason given.
- Deliver it autonomously, without a Codex review — no reason given.

## Open questions

None.
