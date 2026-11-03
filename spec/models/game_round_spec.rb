# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameRound, type: :model do
  def session
    GameSession.create!(shoe_cards: [])
  end

  it "requires a unique number per session" do
    sitting = session
    sitting.game_rounds.create!(number: 1, state: "player_turn", dealer_cards: [])

    expect { sitting.game_rounds.create!(number: 1, state: "finished", dealer_cards: []) }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "accepts an empty dealer_cards array" do
    round = session.game_rounds.create!(number: 1, state: "player_turn", dealer_cards: [])

    expect(round.reload.dealer_cards).to eq([])
  end
end
