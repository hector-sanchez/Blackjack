# frozen_string_literal: true

module Games
  module Blackjack
    class SessionTotals
      def initialize(session)
        @counts = session.round_hands.where.not(outcome: nil).group(:outcome).count
      end

      def wins
        count_for("player_win")
      end

      def losses
        count_for("dealer_win")
      end

      def pushes
        count_for("push")
      end

      def rounds_played
        wins + losses + pushes
      end

      def win_rate
        decided = wins + losses
        return if decided.zero?

        wins / decided.to_f
      end

      private

      def count_for(outcome)
        @counts.fetch(outcome, 0)
      end
    end
  end
end
