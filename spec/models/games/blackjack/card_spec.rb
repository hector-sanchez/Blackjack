# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Card do
  it "creates a card with a suit and rank" do
    card = described_class.new(suit: "hearts", rank: 10)

    expect(card.suit).to eq("hearts")
    expect(card.rank).to eq(10)
  end

  it "rejects an invalid suit or rank" do
    expect { described_class.new(suit: "invalid", rank: 2) }.to raise_error(ArgumentError)
    expect { described_class.new(suit: "hearts", rank: "invalid") }.to raise_error(ArgumentError)
  end

  it "is equal to another card with the same suit and rank" do
    expect(described_class.new(suit: "hearts", rank: 10)).to eq(
      described_class.new(suit: "hearts", rank: 10)
    )
  end
end
