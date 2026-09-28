# Intent

Problem: json gem moving to 3.x breaks apps still on Rails 8.1.3.1 (rails/rails#58685); Gemfile pins `json` below 3.0 to work around it.

Outcome: app runs on Rails 8.1.4, which backports the fix, so the json pin is no longer load-bearing.
