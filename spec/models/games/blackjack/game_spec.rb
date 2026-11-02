# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Game do
  it "starts pending, deals alternately, and leaves the leftover cards" do
    leftover = card(2)
    pending = described_class.new(shoe: shoe_with)

    expect(pending.state).to eq(:pending)
    expect(pending.player_hand.cards).to eq([])
    expect(pending.dealer_hand.cards).to eq([])
    expect(pending.outcome).to eq(nil)

    game = started_game(card(10), card(9), card(7), card(6), leftover)

    expect(game.player_hand.cards).to eq([ card(10), card(7) ])
    expect(game.dealer_hand.cards).to eq([ card(9), card(6) ])
    expect(game.state).to eq(:player_turn)
    expect(game.remaining_cards).to eq([ leftover ])
    expect(game.legal_actions).to eq([ :hit, :stand ])
  end

  it "restores a mid-turn game without dealing" do
    leftover = card(3)
    game = described_class.restore(
      shoe: shoe_with(leftover),
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

  it "finishes immediately on a natural blackjack" do
    player_bj = started_game(card("A"), card(9), card("K"), card(7))
    dealer_bj = started_game(card(10), card("A"), card(9), card("K"))

    expect(player_bj.outcome).to eq(:player_win)
    expect(dealer_bj.outcome).to eq(:dealer_win)
    expect(player_bj.legal_actions).to eq([])
  end

  it "rejects starting twice" do
    game = started_game(card(10), card(9), card(7), card(6))

    expect { game.start! }.to raise_error(Games::Blackjack::Game::InvalidActionError)
  end

  it "hits and continues unless the player busts" do
    extra = card(3)
    game = started_game(card(10), card(9), card(2), card(8), extra)
    game.hit!

    expect(game.player_hand.cards.last).to eq(extra)
    expect(game.state).to eq(:player_turn)

    bust = started_game(card(10), card(9), card(6), card(8), card("K"))
    bust.hit!

    expect(bust.outcome).to eq(:dealer_win)
  end

  it "stands so the dealer draws to 17" do
    dealer_hit = card(5)
    twenty_one = started_game(card(10), card(10), card(9), card(6), dealer_hit)
    twenty_one.stand!

    expect(twenty_one.dealer_hand.cards.last).to eq(dealer_hit)
    expect(twenty_one.dealer_hand.total).to eq(21)
    expect(twenty_one).to be_finished

    bust = started_game(card(10), card(10), card(9), card(6), card("K"))
    bust.stand!

    expect(bust.outcome).to eq(:player_win)
  end

  it "hides the hole card until the round finishes" do
    upcard = card(10)
    hole = card(7)
    game = started_game(card(10, suit: "hearts"), upcard, card(8), hole)

    expect(game.visible_dealer_cards).to eq([ upcard ])

    game.stand!

    expect(game.visible_dealer_cards).to eq([ upcard, hole ])
  end
end
