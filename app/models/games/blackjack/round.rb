# frozen_string_literal: true

module Games
  module Blackjack
    class Round
      class InvalidActionError < StandardError; end

      attr_reader :player_hand, :dealer_hand, :state, :outcome

      def initialize(shoe:, player_hand: nil, dealer_hand: nil, state: :pending, outcome: nil)
        @shoe = shoe
        @player_hand = player_hand || Hand.new
        @dealer_hand = dealer_hand || Hand.new
        @state = state
        @outcome = outcome
      end

      def self.restore(shoe:, player_hand:, dealer_hand:, state:, outcome:)
        new(
          shoe: shoe,
          player_hand: player_hand,
          dealer_hand: dealer_hand,
          state: state,
          outcome: outcome
        )
      end

      def start!
        require_state!(:pending)
        raise Shoe::EmptyError if @shoe.remaining < 4

        2.times do
          @player_hand.add_card(@shoe.draw)
          @dealer_hand.add_card(@shoe.draw)
        end

        if @player_hand.blackjack? || @dealer_hand.blackjack?
          finish!(Rules.outcome(@player_hand, @dealer_hand))
        else
          @state = :player_turn
        end
      end

      def hit!
        require_player_action!(:hit)

        @player_hand.add_card(@shoe.draw)
        finish!(:dealer_win) if @player_hand.busted?
      end

      def stand!
        require_player_action!(:stand)

        @dealer_hand.add_card(@shoe.draw) while Rules.dealer_hits?(@dealer_hand)
        finish!(Rules.outcome(@player_hand, @dealer_hand))
      end

      def legal_actions
        return [] unless @state == :player_turn

        Rules.legal_actions(@player_hand)
      end

      def finished?
        @state == :finished
      end

      def visible_dealer_cards
        return [] if @state == :pending
        return @dealer_hand.cards if finished?

        [ @dealer_hand.cards.first ]
      end

      private

      def require_player_action!(action)
        require_state!(:player_turn)
        raise InvalidActionError unless legal_actions.include?(action)
      end

      def require_state!(expected)
        raise InvalidActionError unless @state == expected
      end

      def finish!(result)
        @outcome = result
        @state = :finished
      end
    end
  end
end
