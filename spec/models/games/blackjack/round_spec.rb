# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Round do
  it "starts pending, deals alternately, and leaves the leftover cards in the shoe" do
    leftover = card(2)
    shoe = shoe_with(card(10), card(9), card(7), card(6), leftover)
    pending = described_class.new(shoe: shoe)

    expect(pending.state).to eq(:pending)
    expect(pending.player_hand.cards).to eq([])
    expect(pending.dealer_hand.cards).to eq([])
    expect(pending.outcome).to eq(nil)

    round = started_round(card(10), card(9), card(7), card(6), leftover)

    expect(round.player_hand.cards).to eq([ card(10), card(7) ])
    expect(round.dealer_hand.cards).to eq([ card(9), card(6) ])
    expect(round.state).to eq(:player_turn)
    expect(round.legal_actions).to eq([ :hit, :stand ])
  end

  it "restores a mid-turn round without dealing" do
    leftover = card(3)
    round = described_class.restore(
      shoe: shoe_with(leftover),
      player_hand: hand_with(10, 7),
      dealer_hand: hand_with(9, 6),
      state: :player_turn,
      outcome: nil
    )

    expect(round.state).to eq(:player_turn)
    expect(round.player_hand.cards).to eq([ card(10), card(7) ])
    expect(round.dealer_hand.cards).to eq([ card(9), card(6) ])
  end

  it "finishes immediately on a natural blackjack" do
    player_bj = started_round(card("A"), card(9), card("K"), card(7))
    dealer_bj = started_round(card(10), card("A"), card(9), card("K"))

    expect(player_bj.outcome).to eq(:player_win)
    expect(dealer_bj.outcome).to eq(:dealer_win)
    expect(player_bj.legal_actions).to eq([])
  end

  it "rejects starting twice" do
    round = started_round(card(10), card(9), card(7), card(6))

    expect { round.start! }.to raise_error(Games::Blackjack::Round::InvalidActionError)
  end

  it "hits and continues unless the player busts" do
    extra = card(3)
    round = started_round(card(10), card(9), card(2), card(8), extra)
    round.hit!

    expect(round.player_hand.cards.last).to eq(extra)
    expect(round.state).to eq(:player_turn)

    bust = started_round(card(10), card(9), card(6), card(8), card("K"))
    bust.hit!

    expect(bust.outcome).to eq(:dealer_win)
  end

  it "stands so the dealer draws to 17" do
    dealer_hit = card(5)
    twenty_one = started_round(card(10), card(10), card(9), card(6), dealer_hit)
    twenty_one.stand!

    expect(twenty_one.dealer_hand.cards.last).to eq(dealer_hit)
    expect(twenty_one.dealer_hand.total).to eq(21)
    expect(twenty_one).to be_finished

    bust = started_round(card(10), card(10), card(9), card(6), card("K"))
    bust.stand!

    expect(bust.outcome).to eq(:player_win)
  end

  it "hides the hole card until the round finishes" do
    upcard = card(10)
    hole = card(7)
    round = started_round(card(10, suit: "hearts"), upcard, card(8), hole)

    expect(round.visible_dealer_cards).to eq([ upcard ])

    round.stand!

    expect(round.visible_dealer_cards).to eq([ upcard, hole ])
  end
end
