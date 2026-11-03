# frozen_string_literal: true

class GameSession < ApplicationRecord
  has_many :game_seats, dependent: :destroy
  has_many :game_rounds, dependent: :destroy
  has_many :round_hands, through: :game_rounds

  enum :status, {
    active: "active",
    completed: "completed"
  }

  validates :status, presence: true
end
