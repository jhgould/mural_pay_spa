# Mural Pay

A Rails application for seamless international payouts, built for the Mural Pay coding challenge. The app implements customer and account creation, payout requests, execution, and live status tracking. Smart translation is powered by OpenAI (ChatGPT). The codebase is modular, scalable, and easy to test.

---

## Stack

- Ruby on Rails 7 — full-stack framework
- Turbo (Hotwire) — SPA-like UI interactions without custom JavaScript
- Bootstrap — for UI styling
- Faraday — API client for Mural Pay and OpenAI
- PostgreSQL — relational database
- OpenAI (ChatGPT) — for memo translation and smart message generation
- RSpec — for feature and integration testing

---

## Core Features

1. Customer & account creation
    - Users can create Mural Pay customers and accounts through the UI. Accounts are saved locally to enable fast lookups and status tracking.
2. Payout request creation
    - Users can initiate a payout for any saved account. The payout form supports AI-driven memo translation via OpenAI.
3. Payout request execution
    - Execute payout requests with a single click. Success and failure states are handled with clear, user-friendly error messages.
4. View payout requests and statuses
    - View all payout requests and their real-time statuses for any given account.
5. Integration with a public API (OpenAI)
    - Transfer description fields can be automatically translated or reworded using OpenAI GPT-4, enhancing recipient communication.

---

## Design and Architecture

- All external API interactions are encapsulated in dedicated service classes, allowing for modular, maintainable, and easily testable code.
- The app uses Turbo (Hotwire) for dynamic user interface updates, enabling SPA-like navigation and responsiveness with minimal JavaScript.
- Bootstrap provides rapid and consistent UI styling.
- Custom error handling ensures that API errors are surfaced clearly to users, with Turbo support for seamless error display and redirection.
- RSpec is used to test feature flows and API interactions, ensuring reliability for all major paths.

### Rationale

- Service object pattern for external APIs ensures each integration is isolated, maintainable, and easy to extend if the codebase grows.
- Turbo is used for its modern Rails-native approach to dynamic UIs without a heavy JS framework.
- AI-driven translation for payout memos offers a real-world value-add for international payments.
- The codebase is organized for clarity, maintainability, and demonstration of Rails best practices, even for a coding challenge scenario.

---

## Roadmap

- Customer and account management
- Payout creation and execution
- Real-time payout status viewing
- OpenAI-powered smart translation
- Robust error handling and Turbo integration
- Natural language payout creation (future with function calling)

