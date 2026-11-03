# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::CardSerializer do
  it "dumps cards and loads string or symbol keys without shuffling" do
    ten = card(10)
    dumped = described_class.dump([ ten ])

    expect(dumped).to eq([ { "rank" => 10, "suit" => "spades" } ])
    expect(described_class.load(dumped)).to eq([ ten ])
    expect(described_class.load([ { rank: "A", suit: "hearts" } ])).to eq([ card("A", suit: "hearts") ])
  end
end
