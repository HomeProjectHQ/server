class CreateTvSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :tv_seasons do |t|
      t.references :tv_show, null: false, foreign_key: true
      t.integer :season_number
      t.string :name
      t.text :overview
      t.string :poster_path
      t.date :air_date

      t.timestamps
    end
  end
end
