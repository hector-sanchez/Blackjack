# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::SessionManager do
  def create_session(*cards)
    game = started_game(*cards)

    GameSession.create!(
      state: Games::Blackjack::GameSerializer.new(game).to_snapshot_h,
      status: game.finished? ? "completed" : "active"
    )
  end

  describe ".start!" do
    it "creates a dealt, loadable session" do
      expect { described_class.start! }.to change(GameSession, :count).by(1)

      session = GameSession.last
      game = described_class.load(session)

      expect(game.player_hand.cards.size).to eq(2)
      expect(game.dealer_hand.cards.size).to eq(2)
      expect(session.status).to eq(game.finished? ? "completed" : "active")
    end
  end

  describe ".hit!" do
    it "persists the drawn card" do
      session = create_session(card(10), card(9), card(7), card(6), card(4))

      described_class.hit!(session)

      restored = described_class.load(session.reload)
      expect(restored.player_hand.cards).to eq([ card(10), card(7), card(4) ])
      expect(session.status).to eq("active")
    end
  end

  describe ".stand!" do
    it "persists the finished round" do
      session = create_session(card(10), card(9), card(9), card(6), card("K"))

      described_class.stand!(session)

      restored = described_class.load(session.reload)
      expect(restored.outcome).to eq(:player_win)
      expect(session.status).to eq("completed")
    end
  end

  it "does not persist an illegal action" do
    session = create_session(card("A"), card(9), card("K"), card(7))
    original_state = session.state.deep_dup

    expect { described_class.hit!(session) }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    expect(session.reload.state).to eq(original_state)
  end
end
