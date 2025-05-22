# Mural Pay SPA

A single-page Rails application that interacts with the Mural Pay sandbox API to support international payouts. The app will include multilingual support and AI-assisted message generation.

---

## 🧱 Stack

- **Ruby on Rails 7** — full-stack framework (non-API mode)
- **Hotwire (Turbo + Stimulus)** — SPA behavior without a JS frontend framework
- **PostgreSQL** — relational database
- **Bootstrap** — for styling
- **HTTParty** — API integration with Mural Pay and other external services
- **Google Cloud Translate API** — for translating transfer descriptions
- **OpenAI (ChatGPT)** — for generating smart transfer messages and natural language-based payout setup

---

## 📦 Features

### Phase 1 – Core Mural Integration
- [ ] Create and view accounts
- [ ] Create payout requests
- [ ] Execute and cancel payouts
- [ ] View payout statuses

### Phase 2 – Translation Support
- [ ] Detect or select recipient language
- [ ] Translate memo/description fields using Google Translate

### Phase 3 – AI Integration (ChatGPT)
- [ ] Rewrite or generate transfer messages
- [ ] Add tone/style (friendly, formal, etc.)
- [ ] Use function calling to pre-fill payout forms from natural language

---
