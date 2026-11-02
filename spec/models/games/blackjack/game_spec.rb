# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Game do
  it "deals a round from the shoe" do
    leftover = card(2)
    game = started_game(card(10), card(9), card(7), card(6), leftover)

    expect(game.player_hand.cards).to eq([ card(10), card(7) ])
    expect(game.dealer_hand.cards).to eq([ card(9), card(6) ])
    expect(game.state).to eq(:player_turn)
    expect(game.remaining_cards).to eq([ leftover ])
  end

  it "deals the next round from what is left in the shoe" do
    game = started_game(card("A"), card(9), card("K"), card(7), card(10), card(8), card(5), card(6))
    game.deal!

    expect(game.player_hand.cards).to eq([ card(10), card(5) ])
    expect(game.dealer_hand.cards).to eq([ card(8), card(6) ])
    expect(game.remaining_cards).to eq([])
  end

  it "rejects dealing until the current round is over" do
    game = started_game(card(10), card(9), card(7), card(6))

    expect { game.deal! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
  end
end
