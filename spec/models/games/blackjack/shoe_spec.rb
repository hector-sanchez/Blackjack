# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::Shoe do
  subject(:shoe) { described_class.new }

  it "builds a shuffled one-deck shoe by default" do
    expect(shoe.remaining).to eq(52)
    expect(shoe.cards.map(&:suit).uniq.size).to eq(4)
    expect(shoe.cards.map(&:rank).uniq.size).to eq(13)
  end

  it "combines one or more decks without emptying them" do
    first = Games::Blackjack::Deck.new
    original = first.remaining

    expect(described_class.new(deck_count: 2).remaining).to eq(104)

    combined = described_class.new(decks: [ first, Games::Blackjack::Deck.new ])
    combined.draw

    expect(first.remaining).to eq(original)
    expect(combined.remaining).to eq(103)
  end

  it "uses the provided cards without shuffling and owns that list" do
    cards = [ card("A"), card(10) ]
    custom = described_class.new(cards: cards)
    cards.clear

    expect(custom.draw).to eq(card("A"))
    expect(custom.draw).to eq(card(10))
    expect(custom).to be_empty
  end

  it "does not let callers mutate the shoe through the reader" do
    shoe.cards.clear

    expect(shoe.remaining).to eq(52)
  end

  it "shuffles the cards" do
    custom = described_class.new(cards: Games::Blackjack::Deck.new.cards)
    original = custom.cards.map { |c| [ c.suit, c.rank ] }

    custom.shuffle!

    expect(custom.cards.map { |c| [ c.suit, c.rank ] }).not_to eq(original)
  end

  it "draws from the front and raises when empty" do
    custom = described_class.new(cards: [ card("A"), card(10) ])

    expect(custom.draw).to eq(card("A"))
    expect(custom.remaining).to eq(1)

    empty = described_class.new(cards: [])
    expect { empty.draw }.to raise_error(Games::Blackjack::Shoe::EmptyError)
    expect(empty).to be_empty
  end

  it "rejects invalid card sources" do
    expect { described_class.new(deck_count: 2, cards: [ card("A") ]) }.to raise_error(ArgumentError)
    expect { described_class.new(deck_count: 0) }.to raise_error(ArgumentError)
    expect { described_class.new(deck_count: -1) }.to raise_error(ArgumentError)
    expect { described_class.new(deck_count: 1.5) }.to raise_error(ArgumentError)
    expect { described_class.new(decks: []) }.to raise_error(ArgumentError)
    expect { described_class.new(decks: [ card("A") ]) }.to raise_error(ArgumentError)
  end
end
