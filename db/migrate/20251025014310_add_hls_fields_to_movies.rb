class AddHlsFieldsToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :hls_path, :string
    add_column :movies, :status, :string
    add_column :movies, :duration, :integer
  end
end
