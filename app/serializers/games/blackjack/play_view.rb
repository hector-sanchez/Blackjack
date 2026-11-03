# frozen_string_literal: true

module Games
  module Blackjack
    class PlayView
      def initialize(round)
        @round = round
      end

      def to_public_h
        {
          state: @round.state.to_s,
          outcome: @round.outcome&.to_s,
          player_cards: card_hashes(@round.player_hand.cards),
          dealer_cards: public_dealer_cards,
          legal_actions: @round.legal_actions.map(&:to_s)
        }
      end

      private

      def card_hashes(cards)
        cards.map { |card| { suit: card.suit, rank: card.rank } }
      end

      def public_dealer_cards
        known = card_hashes(@round.visible_dealer_cards)
        return known unless @round.state == :player_turn && known.any?

        known + [ { hidden: true } ]
      end
    end
  end
end
