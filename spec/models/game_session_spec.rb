# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameSession, type: :model do
  it "defaults to active and accepts an empty shoe" do
    session = described_class.create!(shoe_cards: [])

    expect(session.reload.shoe_cards).to eq([])
    expect(session).to be_active
  end

  it "accepts completed and rejects unknown statuses" do
    expect(described_class.create!(shoe_cards: [], status: "completed")).to be_completed
    expect { described_class.new(shoe_cards: [], status: "unknown") }.to raise_error(ArgumentError)
  end
end
