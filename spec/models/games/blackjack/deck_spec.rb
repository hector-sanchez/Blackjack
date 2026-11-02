# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Deck do
  subject(:deck) { described_class.new }

  it "builds a standard 52-card deck by default" do
    expect(deck.remaining).to eq(52)
    expect(deck.cards.map(&:suit).uniq.size).to eq(4)
    expect(deck.cards.map(&:rank).uniq.size).to eq(13)
  end

  it "uses the provided cards and owns that list" do
    cards = [ card("A"), card(10) ]
    custom = described_class.new(cards: cards)

    cards.clear

    expect(custom.draw).to eq(card("A"))
    expect(custom.draw).to eq(card(10))
    expect(custom).to be_empty
  end

  it "does not let callers mutate the deck through the reader" do
    deck.cards.clear

    expect(deck.remaining).to eq(52)
  end

  it "shuffles the cards" do
    original = deck.cards.map { |c| [ c.suit, c.rank ] }

    deck.shuffle!

    expect(deck.cards.map { |c| [ c.suit, c.rank ] }).not_to eq(original)
  end

  it "draws from the front and reports what remains" do
    first = deck.cards.first

    expect(deck.draw).to eq(first)
    expect(deck.remaining).to eq(51)
  end

  it "raises when drawing from an empty deck" do
    custom = described_class.new(cards: [])

    expect { custom.draw }.to raise_error(Games::Blackjack::Deck::EmptyError)
    expect(custom).to be_empty
  end
end
