# Blackjack

A Rails application for playing Blackjack against the dealer.

Players can deal, hit, and stand. The dealer stands on soft 17, and the hole card remains hidden until the round ends. Natural blackjacks resolve immediately.

No betting, splits, or additional games are supported.

## Tech Stack

- Ruby on Rails
- PostgreSQL
- Hotwire (Turbo)
- RSpec

## Getting Started

Install the required Ruby version and PostgreSQL, then run:

```bash
bin/setup
```

Start the application:

```bash
bin/rails server
```

Visit `http://localhost:3000` to play.

## Running Tests

Run the test suite:

```bash
bundle exec rspec
```

The suite includes unit, request, and system specs.

## Architecture

Blackjack rules are implemented in plain Ruby, independently of Rails and Active Record.

`GameSession` persists game state between requests, while `SessionManager` coordinates gameplay and persistence.

`GameSerializer` provides separate representations for persistence and player-facing data, keeping the dealer's hidden card and remaining deck private.

## Limitations

- Single-player games only
- No betting, splitting, doubling down, or insurance
- Each game starts with a freshly shuffled deck
