# frozen_string_literal: true

class GameSeat < ApplicationRecord
  belongs_to :game_session
  has_many :round_hands, dependent: :restrict_with_error

  validates :position, :name, presence: true
end
