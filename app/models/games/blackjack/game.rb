# frozen_string_literal: true

module Games
  module Blackjack
    class Game
      class InvalidActionError < StandardError; end

      attr_reader :round

      def initialize(shoe: nil, round: nil)
        @shoe = shoe || Shoe.new
        @round = round
      end

      def self.restore(shoe:, round:)
        new(shoe: shoe, round: round)
      end

      def deal!
        raise InvalidActionError if @round && !@round.finished?

        @round = Round.new(shoe: @shoe)
        @round.start!
        self
      end

      def hit!
        current_round.hit!
      end

      def stand!
        current_round.stand!
      end

      def player_hand
        current_round.player_hand
      end

      def dealer_hand
        current_round.dealer_hand
      end

      def state
        current_round.state
      end

      def outcome
        current_round.outcome
      end

      def legal_actions
        return [] unless @round

        @round.legal_actions
      end

      def finished?
        @round&.finished? || false
      end

      def visible_dealer_cards
        return [] unless @round

        @round.visible_dealer_cards
      end

      def remaining_cards
        @shoe.cards
      end

      private

      def current_round
        raise InvalidActionError unless @round

        @round
      end
    end
  end
end
