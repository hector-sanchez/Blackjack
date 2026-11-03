# frozen_string_literal: true

module Games
  module Blackjack
    class CardSerializer
      def self.dump(cards)
        cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
      end

      def self.load(data)
        data.map do |attributes|
          attributes = attributes.stringify_keys
          Card.new(
            rank: attributes.fetch("rank"),
            suit: attributes.fetch("suit")
          )
        end
      end
    end
  end
end
