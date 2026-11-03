# frozen_string_literal: true

class CreateRoundHands < ActiveRecord::Migration[8.1]
  def change
    create_table :round_hands do |t|
      t.references :game_round, null: false, foreign_key: true, index: false
      t.references :game_seat, null: false, foreign_key: true
      t.jsonb :cards, null: false, default: []
      t.string :status, null: false
      t.string :outcome

      t.timestamps
    end

    add_index :round_hands, [ :game_round_id, :game_seat_id ], unique: true
  end
end
