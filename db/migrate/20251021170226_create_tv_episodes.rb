class CreateTvEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :tv_episodes do |t|
      t.references :tv_season, null: false, foreign_key: true
      t.integer :episode_number
      t.string :title
      t.text :overview
      t.date :air_date
      t.integer :runtime
      t.string :still_path
      t.string :file_path
      t.bigint :file_size

      t.timestamps
    end
  end
end
