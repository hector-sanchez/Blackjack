# frozen_string_literal: true

class RoundHand < ApplicationRecord
  belongs_to :game_round
  belongs_to :game_seat

  validates :status, presence: true
end
