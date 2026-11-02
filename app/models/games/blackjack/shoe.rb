# frozen_string_literal: true

module Games
  module Blackjack
    class Shoe
      class EmptyError < StandardError; end

      def initialize(decks: nil, deck_count: nil, cards: nil)
        raise ArgumentError if [ decks, deck_count, cards ].compact.size > 1
        raise ArgumentError unless deck_count.nil? || positive_integer?(deck_count)
        raise ArgumentError unless decks.nil? || decks_source?(decks)

        @cards =
          if cards
            cards.dup
          elsif decks
            combine(decks)
          else
            combine(Array.new(deck_count || 1) { Deck.new })
          end

        shuffle! unless cards
      end

      def cards
        @cards.dup
      end

      def shuffle!
        @cards.shuffle!
        self
      end

      def draw
        raise EmptyError if empty?

        @cards.shift
      end

      def remaining
        @cards.size
      end

      def empty?
        @cards.empty?
      end

      private

      def combine(decks)
        decks.flat_map(&:cards)
      end

      def positive_integer?(value)
        value.is_a?(Integer) && value.positive?
      end

      def decks_source?(value)
        value.is_a?(Array) && value.any? && value.all?(Deck)
      end
    end
  end
end
