# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::SessionManager do
  def start_with(*ranks)
    stub_shoe(*ranks)
    described_class.start!
  end

  describe ".start!" do
    it "creates one seat, one round, and one hand and loads two cards each" do
      expect { start_with(10, 9, 7, 6) }
        .to change(GameSession, :count).by(1)
        .and change(GameSeat, :count).by(1)
        .and change(GameRound, :count).by(1)
        .and change(RoundHand, :count).by(1)

      session = GameSession.last
      seat = session.game_seats.first
      expect(seat.name).to eq("You")
      expect(seat.position).to eq(1)

      round = described_class.load(session)
      expect(round.player_hand.cards).to eq([ card(10), card(7) ])
      expect(round.dealer_hand.cards).to eq([ card(9), card(6) ])
    end

    it "asks Shoe for a new shuffled shoe" do
      expect(Games::Blackjack::Shoe).to receive(:new).with(no_args).and_call_original

      described_class.start!
    end

    it "persists a mid-turn round with a nil outcome" do
      session = start_with(10, 9, 7, 6)
      record = session.game_rounds.last
      hand = record.round_hands.first

      expect(record.state).to eq("player_turn")
      expect(hand.outcome).to be_nil
      expect(hand.status).to eq("playing")
    end
  end

  describe ".hit!" do
    it "adds a card to the same hand without inserting a round" do
      session = start_with(10, 9, 7, 6, 4)

      expect { described_class.hit!(session) }.not_to change { session.game_rounds.count }

      hand = session.round_hands.first
      expect(hand.reload.cards).to eq(Games::Blackjack::CardSerializer.dump([ card(10), card(7), card(4) ]))
      expect(session.reload.shoe_cards).to eq([])
    end

    it "busts the same round" do
      session = start_with(10, 9, 7, 6, "K")

      described_class.hit!(session)

      record = session.game_rounds.last.reload
      hand = record.round_hands.first
      expect(session.game_rounds.count).to eq(1)
      expect(record.state).to eq("finished")
      expect(hand.status).to eq("busted")
      expect(hand.outcome).to eq("dealer_win")
    end
  end

  describe ".stand!" do
    it "finalizes the same round with a stood status and an outcome" do
      session = start_with(10, 9, 9, 6, "K")

      described_class.stand!(session)

      record = session.game_rounds.last.reload
      hand = record.round_hands.first
      expect(session.game_rounds.count).to eq(1)
      expect(record.state).to eq("finished")
      expect(hand.status).to eq("stood")
      expect(hand.outcome).to eq("player_win")
    end
  end

  describe "naturals" do
    it "persists a finished natural as blackjack and a player win" do
      session = start_with("A", 9, "K", 7)
      record = session.game_rounds.last
      hand = record.round_hands.first

      expect(session.game_rounds.count).to eq(1)
      expect(record.state).to eq("finished")
      expect(hand.status).to eq("blackjack")
      expect(hand.outcome).to eq("player_win")
      expect(hand.cards.size).to eq(2)
      expect(record.dealer_cards.size).to eq(2)
    end

    it "persists a both-natural as blackjack and a push" do
      session = start_with("A", "A", "K", "K")
      hand = session.round_hands.first

      expect(hand.status).to eq("blackjack")
      expect(hand.outcome).to eq("push")
    end
  end

  describe ".deal!" do
    it "inserts round 2 without changing round 1" do
      session = start_with("A", 9, "K", 7, 10, 8, 5, 6)
      first = session.round_hands.first
      first_cards = first.cards.deep_dup
      first_outcome = first.outcome

      described_class.deal!(session)

      expect(session.game_rounds.count).to eq(2)
      expect(first.reload.cards).to eq(first_cards)
      expect(first.outcome).to eq(first_outcome)

      restored = described_class.load(session.reload)
      expect(restored.player_hand.cards).to eq([ card(10), card(5) ])
      expect(restored.dealer_hand.cards).to eq([ card(8), card(6) ])
    end

    it "does not insert a round while the player is still acting" do
      session = start_with(10, 9, 7, 6)

      expect { described_class.deal!(session) }
        .to raise_error(Games::Blackjack::SessionManager::InvalidActionError)
      expect(session.game_rounds.count).to eq(1)
    end
  end

  it "restores leftover shoe order without reshuffling" do
    session = start_with(10, 9, 7, 6, 2)
    session.update!(shoe_cards: Games::Blackjack::CardSerializer.dump([ card(4) ]))

    described_class.hit!(session)

    expect(session.round_hands.first.reload.cards.last).to eq(Games::Blackjack::CardSerializer.dump([ card(4) ]).first)
  end

  it "does not persist an illegal hit after a natural" do
    session = start_with("A", 9, "K", 7)
    cards = session.round_hands.first.cards.deep_dup

    expect { described_class.hit!(session) }
      .to raise_error(Games::Blackjack::Round::InvalidActionError)
    expect(session.round_hands.first.reload.cards).to eq(cards)
    expect(session.game_rounds.count).to eq(1)
  end
end
