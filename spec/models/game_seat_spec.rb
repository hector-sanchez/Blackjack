# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameSeat, type: :model do
  def session
    GameSession.create!(shoe_cards: [])
  end

  it "requires a unique position per session and allows duplicate names" do
    sitting = session
    sitting.game_seats.create!(position: 1, name: "You")
    sitting.game_seats.create!(position: 2, name: "You")

    expect { sitting.game_seats.create!(position: 1, name: "Other") }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "rejects destroy when a round hand exists" do
    sitting = session
    seat = sitting.game_seats.create!(position: 1, name: "You")
    round = sitting.game_rounds.create!(number: 1, state: "player_turn", dealer_cards: [])
    round.round_hands.create!(game_seat: seat, cards: [], status: "playing")

    expect { seat.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
  end
end
