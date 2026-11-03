# frozen_string_literal: true

class MoveSessionShoe < ActiveRecord::Migration[8.1]
  def change
    remove_column :game_sessions, :state, :jsonb, default: {}, null: false
    add_column :game_sessions, :shoe_cards, :jsonb, null: false, default: []
  end
end
