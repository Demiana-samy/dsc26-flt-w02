# AI usage: dsc26-flt-w02

## 1. Tools I used

- ChatGPT for understanding the requirements, reviewing the implementation steps, and troubleshooting Flutter commands.
- Antigravity for assistance with the Flutter task.

## 2. The two or three most useful prompts

1. Explain the requirements for the StockAlert model, including JSON validation, copyWith, and value equality.
2. Help implement the AlertsViewModel with the required sorting, filtering, Arabic search normalization, and acknowledge behavior.
3. Review the Flutter screen against the required widget keys and loading, empty, and list states.

## 3. One thing the AI got wrong or left out, and how I found it

The initial setup needed a different Flutter SDK version to satisfy the project's version constraints. I checked the SDK version and updated Flutter before running the tests.

## 4. Why visibleAlerts lives in the view model and not in the screen

The view model owns filtering, searching, and sorting so these rules stay in one place and can be tested independently of the UI. The screen only displays the resulting list and forwards user actions to the view model.