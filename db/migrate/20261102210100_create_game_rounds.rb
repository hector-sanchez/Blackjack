# frozen_string_literal: true

class CreateGameRounds < ActiveRecord::Migration[8.1]
  def change
    create_table :game_rounds do |t|
      t.references :game_session, null: false, foreign_key: true, index: false
      t.integer :number, null: false
      t.string :state, null: false
      t.jsonb :dealer_cards, null: false, default: []

      t.timestamps
    end

    add_index :game_rounds, [ :game_session_id, :number ], unique: true
  end
end
