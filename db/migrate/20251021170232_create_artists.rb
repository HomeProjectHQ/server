class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :mbid
      t.text :bio
      t.string :image_url
      t.string :country

      t.timestamps
    end
  end
end
