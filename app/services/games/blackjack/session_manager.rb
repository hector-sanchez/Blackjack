# frozen_string_literal: true

module Games
  module Blackjack
    class SessionManager
      def self.start!
        game = Game.new
        game.deal!

        GameSession.create!(
          state: GameSerializer.new(game).to_snapshot_h,
          status: "active"
        )
      end

      def self.load(session)
        GameSerializer.load(session.state)
      end

      def self.hit!(session)
        perform_action!(session, :hit)
      end

      def self.stand!(session)
        perform_action!(session, :stand)
      end

      def self.deal!(session)
        perform_action!(session, :deal)
      end

      def self.perform_action!(session, action)
        session.with_lock do
          game = load(session)

          case action
          when :hit
            game.hit!
          when :stand
            game.stand!
          when :deal
            game.deal!
          end

          session.update!(
            state: GameSerializer.new(game).to_snapshot_h,
            status: "active"
          )

          game
        end
      end

      private_class_method :perform_action!
    end
  end
end
