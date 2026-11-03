# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::PlayView do
  def card_hash(card)
    { suit: card.suit, rank: card.rank }
  end

  it "hides the hole card during the player turn" do
    round = started_round(card(10), card(9), card(7), card(6), card(2))

    expect(described_class.new(round).to_public_h).to eq(
      state: "player_turn",
      outcome: nil,
      player_cards: [ card_hash(card(10)), card_hash(card(7)) ],
      dealer_cards: [ card_hash(card(9)), { hidden: true } ],
      legal_actions: [ "hit", "stand" ]
    )
  end

  it "reveals the dealer hand when the round is finished" do
    round = started_round(card("A"), card(9), card("K"), card(7))

    expect(described_class.new(round).to_public_h).to eq(
      state: "finished",
      outcome: "player_win",
      player_cards: [ card_hash(card("A")), card_hash(card("K")) ],
      dealer_cards: [ card_hash(card(9)), card_hash(card(7)) ],
      legal_actions: []
    )
  end
end
