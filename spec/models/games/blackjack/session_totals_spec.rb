# frozen_string_literal: true

require "rails_helper"

RSpec.describe Games::Blackjack::SessionTotals do
  def sitting_with(*outcomes)
    session = GameSession.create!(shoe_cards: [])
    seat = session.game_seats.create!(position: 1, name: "You")
    outcomes.each.with_index(1) do |outcome, number|
      state = outcome ? "finished" : "player_turn"
      status = outcome ? "stood" : "playing"
      round = session.game_rounds.create!(number: number, state: state, dealer_cards: [])
      round.round_hands.create!(game_seat: seat, cards: [], status: status, outcome: outcome)
    end
    session
  end

  it "counts finished hands and excludes pushes from win rate" do
    totals = described_class.new(sitting_with("player_win", "dealer_win", "push"))

    expect(totals.wins).to eq(1)
    expect(totals.losses).to eq(1)
    expect(totals.pushes).to eq(1)
    expect(totals.rounds_played).to eq(3)
    expect(totals.win_rate).to eq(0.5)
  end

  it "has no win rate when every finished hand is a push" do
    totals = described_class.new(sitting_with("push"))

    expect(totals.rounds_played).to eq(1)
    expect(totals.win_rate).to be_nil
  end

  it "ignores an in-progress hand" do
    totals = described_class.new(sitting_with("player_win", nil))

    expect(totals.wins).to eq(1)
    expect(totals.rounds_played).to eq(1)
  end
end
