# frozen_string_literal: true

require "rails_helper"

RSpec.describe GameSession, type: :model do
  def valid_attributes
    {
      state: { "any" => "payload" },
      status: "active"
    }
  end

  it "persists a nonempty state hash and defaults to active" do
    session = described_class.create!(valid_attributes.except(:status))

    expect(session.reload.state).to eq(valid_attributes[:state])
    expect(session).to be_active
  end

  it "requires a nonempty state hash" do
    expect(described_class.new(valid_attributes.merge(state: nil))).not_to be_valid
    expect(described_class.new(valid_attributes.merge(state: {}))).not_to be_valid
  end

  it "accepts completed and rejects unknown statuses" do
    expect(described_class.create!(valid_attributes.merge(status: "completed"))).to be_completed
    expect { described_class.new(valid_attributes.merge(status: "unknown")) }.to raise_error(ArgumentError)
  end
end
