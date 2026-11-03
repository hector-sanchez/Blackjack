# frozen_string_literal: true

class CreateGameSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :game_seats do |t|
      t.references :game_session, null: false, foreign_key: true, index: false
      t.integer :position, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :game_seats, [ :game_session_id, :position ], unique: true
  end
end
