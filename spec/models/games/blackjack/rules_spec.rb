# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Rules do
  describe ".legal_actions" do
    it "allows hit and stand below 21" do
      expect(described_class.legal_actions(hand_with(10, 7))).to eq([ :hit, :stand ])
    end

    it "allows only stand at 21" do
      expect(described_class.legal_actions(hand_with(7, 9, 5))).to eq([ :stand ])
    end

    it "allows nothing after a bust or natural blackjack" do
      expect(described_class.legal_actions(hand_with("K", "Q", 5))).to eq([])
      expect(described_class.legal_actions(hand_with("A", "K"))).to eq([])
    end
  end

  describe ".dealer_hits?" do
    it "hits below 17 and stands on 17, including soft 17" do
      expect(described_class.dealer_hits?(hand_with(10, 6))).to eq(true)
      expect(described_class.dealer_hits?(hand_with(10, 7))).to eq(false)
      expect(described_class.dealer_hits?(hand_with("A", 6))).to eq(false)
    end
  end

  describe ".outcome" do
    [
      { player: [ "K", "Q", 2 ], dealer: [ 10, 8 ], result: :dealer_win, case: "player bust" },
      { player: [ "K", "Q", 2 ], dealer: [ "K", "Q", 4 ], result: :dealer_win, case: "player bust even when the dealer also busts" },
      { player: [ 10, 10 ], dealer: [ "K", "Q", 3 ], result: :player_win, case: "dealer bust" },
      { player: [ 10, 10 ], dealer: [ 10, 8 ], result: :player_win, case: "higher player total" },
      { player: [ 10, 9 ], dealer: [ 10, 9 ], result: :push, case: "equal totals" },
      { player: [ "A", "K" ], dealer: [ 7, 9, 5 ], result: :player_win, case: "player natural over ordinary 21" },
      { player: [ 7, 9, 5 ], dealer: [ "A", "K" ], result: :dealer_win, case: "dealer natural over ordinary 21" },
      { player: [ "A", "K" ], dealer: [ "A", 10 ], result: :push, case: "simultaneous naturals" }
    ].each do |scenario|
      it "resolves #{scenario[:case]}" do
        expect(described_class.outcome(hand_with(*scenario[:player]), hand_with(*scenario[:dealer]))).to eq(scenario[:result])
      end
    end
  end
end
