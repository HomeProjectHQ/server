class AddHlsFieldsToSongs < ActiveRecord::Migration[8.0]
  def change
    add_column :songs, :status, :string
    add_column :songs, :hls_path, :string
    add_column :songs, :hls_duration, :integer
    add_column :songs, :hls_qualities, :text
  end
end
