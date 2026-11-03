# frozen_string_literal: true

require "rails_helper"

RSpec.describe RoundHand, type: :model do
  def sitting
    session = GameSession.create!(shoe_cards: [])
    seat = session.game_seats.create!(position: 1, name: "You")
    round = session.game_rounds.create!(number: 1, state: "player_turn", dealer_cards: [])
    [ session, seat, round ]
  end

  it "requires a unique seat per round" do
    _session, seat, round = sitting
    round.round_hands.create!(game_seat: seat, cards: [], status: "playing")

    expect { round.round_hands.create!(game_seat: seat, cards: [], status: "stood") }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "requires status and allows a nil outcome" do
    _session, seat, round = sitting

    expect { round.round_hands.create!(game_seat: seat, cards: []) }
      .to raise_error(ActiveRecord::RecordInvalid)

    hand = round.round_hands.create!(game_seat: seat, cards: [], status: "playing")
    expect(hand.outcome).to be_nil
  end
end
