# frozen_string_literal: true

module Games
  module Blackjack
    class SessionManager
      class InvalidActionError < StandardError; end

      class << self
        def start!
          GameSession.transaction do
            session = GameSession.create!(shoe_cards: [], status: "active")
            session.game_seats.create!(position: 1, name: "You")
            shoe = Shoe.new
            round = Round.new(shoe: shoe)
            round.start!
            insert_round!(session, round)
            persist_shoe!(session, shoe)
            session
          end
        end

        def load(session)
          shoe = leftover_shoe(session)
          restore_round(session, shoe)
        end

        def hit!(session)
          perform_action!(session, :hit)
        end

        def stand!(session)
          perform_action!(session, :stand)
        end

        def deal!(session)
          perform_action!(session, :deal)
        end

        private

        def perform_action!(session, action)
          session.with_lock do
            shoe = leftover_shoe(session)
            round = restore_round(session, shoe)

            case action
            when :hit
              round.hit!
              persist_current_round!(session, round)
            when :stand
              round.stand!
              persist_current_round!(session, round)
            when :deal
              raise InvalidActionError unless round.finished?

              shoe = Shoe.new if shoe.remaining < 4
              round = Round.new(shoe: shoe)
              round.start!
              insert_round!(session, round)
            end

            persist_shoe!(session, shoe)
            round
          end
        end

        def leftover_shoe(session)
          Shoe.new(cards: CardSerializer.load(session.shoe_cards))
        end

        def restore_round(session, shoe)
          record = session.game_rounds.order(:number).last!
          hand = record.round_hands.first!

          Round.restore(
            shoe: shoe,
            player_hand: Hand.new(CardSerializer.load(hand.cards)),
            dealer_hand: Hand.new(CardSerializer.load(record.dealer_cards)),
            state: record.state.to_sym,
            outcome: hand.outcome&.to_sym
          )
        end

        def insert_round!(session, round)
          record = session.game_rounds.create!(
            number: session.game_rounds.maximum(:number).to_i + 1,
            state: round.state.to_s,
            dealer_cards: CardSerializer.dump(round.dealer_hand.cards)
          )
          persist_hand!(record, session, round)
        end

        def persist_current_round!(session, round)
          record = session.game_rounds.order(:number).last!
          record.update!(
            state: round.state.to_s,
            dealer_cards: CardSerializer.dump(round.dealer_hand.cards)
          )
          persist_hand!(record, session, round)
        end

        def persist_hand!(record, session, round)
          attrs = {
            cards: CardSerializer.dump(round.player_hand.cards),
            status: hand_status(round),
            outcome: round.outcome&.to_s
          }
          seat = session.game_seats.order(:position).first!
          hand = record.round_hands.find_by(game_seat: seat)
          if hand
            hand.update!(attrs)
          else
            record.round_hands.create!(attrs.merge(game_seat: seat))
          end
        end

        def persist_shoe!(session, shoe)
          session.update!(shoe_cards: CardSerializer.dump(shoe.cards))
        end

        def hand_status(round)
          hand = round.player_hand
          if hand.blackjack?
            "blackjack"
          elsif hand.busted?
            "busted"
          elsif round.finished?
            "stood"
          else
            "playing"
          end
        end
      end
    end
  end
end
