# frozen_string_literal: true

module Games
  module Blackjack
    class Hand
      def initialize(cards = [])
        @cards = []
        cards.each { |card| add_card(card) }
      end

      def add_card(card)
        raise ArgumentError, "Invalid card" unless card.is_a?(Card)

        @cards << card
      end

      def cards
        @cards.dup
      end

      def total
        score.fetch(:total)
      end

      def soft?
        score.fetch(:soft)
      end

      def blackjack?
        @cards.size == 2 && total == 21
      end

      def busted?
        total > 21
      end

      private

      def score
        total = @cards.sum { |card| value(card) }
        aces = @cards.count { |card| card.rank == "A" }

        while total > 21 && aces.positive?
          total -= 10
          aces -= 1
        end

        { total: total, soft: aces.positive? }
      end

      def value(card)
        # I installed byebug and realized my mistake:
        # I was treating it like an 'if' statement and OR suit == "....".
        # case statement is evaluating rank. So, `when 4 || (suit == "hearts" || suit == "diamonds")` makes no sense.
        # I needed to exit early under those conditions or:
        # `when 4 then if card.suit == "hearts" || card.suit == "diamonds" then 8 else card.rank end`
        # I chose the former.

        return 8 if card.rank == 4 && (card.suit == "hearts" || card.suit == "diamonds")

        case card.rank
        when 4 then if card.suit == "hearts" || card.suit == "diamonds" then 8 else card.rank end
        when "A" then 11
        when "J", "Q", "K" then 10
        else card.rank
        end
      end
    end
  end
end
