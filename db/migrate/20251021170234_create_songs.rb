class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.references :album, null: false, foreign_key: true
      t.integer :track_number
      t.integer :duration
      t.string :file_path
      t.bigint :file_size
      t.string :mbid

      t.timestamps
    end
  end
end
