# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Game do
  describe "#initialize" do
    it "starts pending with empty hands" do
      game = described_class.new(deck: deck_with)

      expect(game.state).to eq(:pending)
      expect(game.player_hand.cards).to eq([])
      expect(game.dealer_hand.cards).to eq([])
      expect(game.outcome).to eq(nil)
    end
  end

  describe ".restore" do
    it "rebuilds a mid-turn game without dealing" do
      leftover = card(3)
      game = described_class.restore(
        deck: deck_with(leftover),
        player_hand: hand_with(10, 7),
        dealer_hand: hand_with(9, 6),
        state: :player_turn,
        outcome: nil
      )

      expect(game.state).to eq(:player_turn)
      expect(game.player_hand.cards).to eq([ card(10), card(7) ])
      expect(game.dealer_hand.cards).to eq([ card(9), card(6) ])
      expect(game.remaining_cards).to eq([ leftover ])
    end
  end

  describe "#start!" do
    it "deals two cards to each participant in alternating order" do
      game = started_game(card(10), card(9), card(7), card(6))

      expect(game.player_hand.cards).to eq([ card(10), card(7) ])
      expect(game.dealer_hand.cards).to eq([ card(9), card(6) ])
      expect(game.state).to eq(:player_turn)
    end

    it "finishes immediately on a natural blackjack" do
      player_bj = started_game(card("A"), card(9), card("K"), card(7))
      expect(player_bj.outcome).to eq(:player_win)

      dealer_bj = started_game(card(10), card("A"), card(9), card("K"))
      expect(dealer_bj.outcome).to eq(:dealer_win)
    end

    it "rejects starting twice" do
      game = started_game(card(10), card(9), card(7), card(6))

      expect { game.start! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
    end
  end

  describe "#hit!" do
    it "adds one card and continues unless the player busts" do
      extra = card(3)
      game = started_game(card(10), card(9), card(2), card(8), extra)
      game.hit!

      expect(game.player_hand.cards.last).to eq(extra)
      expect(game.state).to eq(:player_turn)
    end

    it "finishes with a dealer win when the player busts" do
      game = started_game(card(10), card(9), card(6), card(8), card("K"))
      game.hit!

      expect(game.outcome).to eq(:dealer_win)
    end
  end

  describe "#stand!" do
    it "lets the dealer draw until 17 or higher" do
      dealer_hit = card(5)
      game = started_game(card(10), card(10), card(9), card(6), dealer_hit)
      game.stand!

      expect(game.dealer_hand.cards.last).to eq(dealer_hit)
      expect(game.dealer_hand.total).to eq(21)
      expect(game).to be_finished
    end

    it "finishes with a player win when the dealer busts" do
      game = started_game(card(10), card(10), card(9), card(6), card("K"))
      game.stand!

      expect(game.outcome).to eq(:player_win)
    end
  end

  describe "#legal_actions" do
    it "delegates to the rules during the player turn and is empty otherwise" do
      game = started_game(card(10), card(9), card(7), card(6))
      expect(game.legal_actions).to eq([ :hit, :stand ])

      finished = started_game(card("A"), card(9), card("K"), card(7))
      expect(finished.legal_actions).to eq([])
    end
  end

  describe "#remaining_cards" do
    it "returns the undealt cards" do
      leftover = card(2)
      game = started_game(card(10), card(9), card(7), card(6), leftover)

      expect(game.remaining_cards).to eq([ leftover ])
    end
  end

  describe "#visible_dealer_cards" do
    it "hides the hole card until the round finishes" do
      upcard = card(10)
      hole = card(7)
      game = started_game(card(10, suit: "hearts"), upcard, card(8), hole)

      expect(game.visible_dealer_cards).to eq([ upcard ])

      game.stand!

      expect(game.visible_dealer_cards).to eq([ upcard, hole ])
    end
  end
end
