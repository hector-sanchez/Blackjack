# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Hand do
  it "starts empty" do
    hand = described_class.new

    expect(hand.cards).to eq([])
    expect(hand.total).to eq(0)
  end

  it "adds cards and owns its list" do
    ten = card(10)
    seven = card(7)
    cards = [ ten ]
    hand = described_class.new(cards)

    cards.clear
    hand.add_card(seven)
    hand.cards << card("A")

    expect(hand.cards).to eq([ ten, seven ])
  end

  it "rejects a non-card" do
    expect { described_class.new.add_card("A") }.to raise_error(ArgumentError)
  end

  describe "scoring" do
    [
      { ranks: [ 10, 7 ], total: 17, soft: false, blackjack: false, busted: false },
      { ranks: [ "A", 7 ], total: 18, soft: true, blackjack: false, busted: false },
      { ranks: [ "A", 7, 9 ], total: 17, soft: false, blackjack: false, busted: false },
      { ranks: [ "A", "A" ], total: 12, soft: true, blackjack: false, busted: false },
      { ranks: [ "A", "K" ], total: 21, soft: true, blackjack: true, busted: false },
      { ranks: [ 7, 9, 5 ], total: 21, soft: false, blackjack: false, busted: false },
      { ranks: [ "K", "Q", 5 ], total: 25, soft: false, blackjack: false, busted: true },
      { ranks: [ "A", "A", "A" ], total: 13, soft: true, blackjack: false, busted: false },
      { ranks: [ "A", "A", 9, "K" ], total: 21, soft: false, blackjack: false, busted: false },
      { ranks: [ 10, "A", "K" ], total: 21, soft: false, blackjack: false, busted: false }
    ].each do |scenario|
      it "scores #{scenario[:ranks].join(', ')}" do
        hand = hand_with(*scenario[:ranks])

        expect(hand.total).to eq(scenario[:total])
        expect(hand.soft?).to eq(scenario[:soft])
        expect(hand.blackjack?).to eq(scenario[:blackjack])
        expect(hand.busted?).to eq(scenario[:busted])
      end
    end
  end
end
