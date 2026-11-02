# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::GameSerializer do
  def card_hash(card)
    { suit: card.suit, rank: card.rank }
  end

  describe "#to_snapshot_h" do
    it "serializes hands and the remaining deck after the deal" do
      leftover = card(2)
      game = started_game(card(10), card(9), card(7), card(6), leftover)

      expect(described_class.new(game).to_snapshot_h).to eq(
        state: "player_turn",
        outcome: nil,
        player_cards: [ card_hash(card(10)), card_hash(card(7)) ],
        dealer_cards: [ card_hash(card(9)), card_hash(card(6)) ],
        remaining_cards: [ card_hash(leftover) ]
      )
    end
  end

  describe "#to_public_h" do
    it "hides the hole card and remaining shoe during the player turn" do
      game = started_game(card(10), card(9), card(7), card(6), card(2))

      expect(described_class.new(game).to_public_h).to eq(
        state: "player_turn",
        outcome: nil,
        player_cards: [ card_hash(card(10)), card_hash(card(7)) ],
        dealer_cards: [ card_hash(card(9)), { hidden: true } ],
        legal_actions: [ "hit", "stand" ]
      )
    end

    it "reveals the dealer hand when the round is finished" do
      game = started_game(card("A"), card(9), card("K"), card(7))

      expect(described_class.new(game).to_public_h).to eq(
        state: "finished",
        outcome: "player_win",
        player_cards: [ card_hash(card("A")), card_hash(card("K")) ],
        dealer_cards: [ card_hash(card(9)), card_hash(card(7)) ],
        legal_actions: []
      )
    end
  end

  describe ".load" do
    it "round-trips a snapshot so the game can continue" do
      extra = card(3)
      game = started_game(card(10), card(9), card(2), card(8), extra)
      restored = described_class.load(described_class.new(game).to_snapshot_h)

      expect(restored.state).to eq(game.state)
      expect(restored.player_hand.cards).to eq(game.player_hand.cards)
      expect(restored.dealer_hand.cards).to eq(game.dealer_hand.cards)
      expect(restored.remaining_cards).to eq(game.remaining_cards)

      restored.hit!

      expect(restored.player_hand.cards.last).to eq(extra)
    end
  end
end
