# Review: parent-dashboard-mobile-fit

## Round 1 — 2026-11-05 08:56 UTC — 9cb505f

- [ ] Important: The home-indicator clearance of the tab bar has no automated proof, though the plan's Risks require it when Chrome supports `Emulation.setSafeAreaInsetsOverride`. The local Chrome 157 supports it: with insets `{ top: 50, bottom: 34 }`, `env(safe-area-inset-bottom)` computes to 34px. The tab bar test emulates a 728 px viewport with zero insets, so `app_shell.css` (`--nav-height-mobile` with the inset, `body > header` bottom padding, `body` top padding) never runs with a non-zero inset in any test. Set the insets override in the tab bar test (and the fit tests at 812 px tall) and assert that every tab ends above `812 - 34` — `test/system/parent_dashboard_fit_test.rb:108` → fixed (Test that the tab bar clears the home indicator)
- [ ] Nit: The header comment says every selector is more specific than the mvpa rule it overrides. `:root` and `body` have the same specificity as mvpa's `:root` and `body` rules; they win on load order only. Correct the comment so a later reorder of the imports does not look safe — `app/assets/stylesheets/2_layout/app_shell.css:5` → fixed (Say which app shell rules win on load order)
- [ ] Nit: N+1 per record: `rewardable_sticker_cards_count` calls `rewardable?` on every preloaded card of every child, and each call runs `stickers.positive.count` and `stickers.negative.count` (two or three COUNT queries per card, history included). The branch reduces it (one walk instead of two) and the plan makes no `Query count:` claim, so it is not Important. A follow-up can preload sticker counts — `app/views/parent/children/_dashboard_progress.html.erb:4` → dismissed: pre-existing query pattern that this branch halves; preloading sticker counts is outside the accepted intent and belongs in a follow-up
- [ ] Nit: Law of Demeter: `child.user.reload.name` reaches through the child profile into its user to reload it. Reload the user fixture directly, or compare against the name the test set — `test/system/parent_dashboard_fit_test.rb:165` → fixed (Test that the tab bar clears the home indicator)
- [ ] Nit: Law of Demeter: `Rails.application.routes.url_helpers.parent_child_reward_path(profile)` reaches through three objects. Include `Rails.application.routes.url_helpers` in the test class, as the `dom_id` helper is wrapped — `test/models/child_profile_test.rb:163` → fixed (Include route helpers in the child profile test)

Compliance:

- Three children, none ready, fit without scrolling → `test/system/parent_dashboard_fit_test.rb` "three children with no card ready fit above the tab bar on an iPhone 12 mini"
- Three children, each ready, Mark card given for each, still fit → `test/system/parent_dashboard_fit_test.rb` "three children with a card ready each fit above the tab bar on an iPhone 12 mini"
- Only the ready child's row shows Mark card given → `test/integration/parent/children_dashboard_layout_test.rb` "dashboard shows mark rewarded only in the row of a child with a card ready to reward"
- Tap marks the oldest ready card given, button disappears → `test/system/parent_dashboard_fit_test.rb` "mark rewarded on the dashboard gives the card and removes the button"
- Two ready cards: one tap gives the oldest, button stays → `test/system/parent_dashboard_fit_test.rb` "mark rewarded stays on the dashboard while a second card is ready"
- Card completes live, button appears, rows fit → `test/system/parent_dashboard_fit_test.rb` "mark rewarded appears live when a card completes and the rows still fit"
- Tabs whole, one row, inside viewport for parent, admin, child → `test/system/parent_dashboard_fit_test.rb` "tab bar tabs share one row inside the viewport for parent, admin and child"; above the home indicator → `test/integration/layout_meta_test.rb` (both layouts) plus a manual device check; the automated inset check is missing (Important above)
- No Logout in the tab bar; Preferences → Log out → sign-in page → `test/controllers/navigation_test.rb` "the Dutch nav shows appkit's wording", `test/integration/preferences_test.rb` "preferences page offers log out" and "logging out from preferences lands on the sign-in page"
- Every test named in `## Proof` exists, including the three `child_profile_test.rb` broadcast tests and the long-name Dutch fit test.
- Weakened tests: none. `children_dashboard_layout_test.rb` drops its badge assertion while it reverses the form assertion as the plan requires; `test/integration/parent_ui_test.rb:33` and `:47` still cover the badge. `navigation_test.rb:110` changes as the plan requires.

Checks: touched unit and integration tests 45 runs, 0 failures; `parent_dashboard_fit_test.rb` 7 runs, 0 failures; rubocop and erb_lint clean on the touched files. No new public Ruby method, so `### Signatures` holds. No glossary exists, so no `Avoid:` words apply. Security: nothing found (logout is a CSRF-protected DELETE; the broadcast `button_to` relies on Turbo's `X-CSRF-Token` header, as the child page does).

## Round 2 — 2026-11-05 09:00 UTC — 3fa81f8

No findings.

Closures from round 1, checked against the code:

- Inset proof (fixed, 390f78b): `test "tab bar clears the home indicator and three ready rows still fit on an iPhone 12 mini"` sets `Emulation.setSafeAreaInsetsOverride` with top 50, bottom 34 at 375×812, and asserts every tab link ends at or above 778. Teardown clears the override. The plan's `## Proof` names the test. The coordinator reports the test fails without `app_shell.css` (815 > 778), so it proves the inset rules. Holds.
- Specificity comment (fixed, 1a5781b): `app_shell.css:5-7` now says the `:root` and `body` rules win on load order only. Holds.
- N+1 in `rewardable_sticker_cards_count` (dismissed): the pattern exists on main, the branch halves it, and the plan makes no `Query count:` claim. The reason holds.
- Law of Demeter in the fit test (fixed, 390f78b): `User.find(child.user_id).name` at `parent_dashboard_fit_test.rb:200`. Holds.
- Law of Demeter in the child profile test (fixed, 3fa81f8): the class includes `Rails.application.routes.url_helpers`; `reward_form_selector` calls `parent_child_reward_path` directly. Holds.

Compliance: the round 1 table stands. The home-indicator criterion now has its automated proof. No test is weakened, skipped or deleted in the three new commits.

Design: no new public Ruby method. No glossary exists. No new call chain or query loop in the three new commits.

Checks: `child_profile_test.rb` plus `parent_dashboard_fit_test.rb` 22 runs, 0 failures; rubocop clean on the 6 touched Ruby files. Security: nothing new.
