# frozen_string_literal: true

class GameRound < ApplicationRecord
  belongs_to :game_session
  has_many :round_hands, dependent: :destroy

  validates :number, :state, presence: true
end
