class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.string :title
      t.references :artist, null: false, foreign_key: true
      t.integer :year
      t.string :cover_url
      t.string :mbid

      t.timestamps
    end
  end
end
