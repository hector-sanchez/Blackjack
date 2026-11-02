# frozen_string_literal: true

module Games
  module BlackjackHelpers
    def card(rank, suit: "spades")
      Games::Blackjack::Card.new(rank: rank, suit: suit)
    end

    def deck_with(*cards)
      Games::Blackjack::Deck.new(cards: cards)
    end

    def shoe_with(*cards)
      Games::Blackjack::Shoe.new(cards: cards)
    end

    def hand_with(*ranks)
      Games::Blackjack::Hand.new(ranks.map { |rank| card(rank) })
    end

    def started_round(*cards)
      round = Games::Blackjack::Round.new(shoe: shoe_with(*cards))
      round.start!
      round
    end

    def started_game(*cards)
      game = Games::Blackjack::Game.new(shoe: shoe_with(*cards))
      game.deal!
      game
    end
  end
end
