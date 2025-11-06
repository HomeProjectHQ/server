class AddHlsFieldsToTvEpisodes < ActiveRecord::Migration[8.0]
  def change
    add_column :tv_episodes, :status, :string
    add_column :tv_episodes, :hls_path, :string
    add_column :tv_episodes, :hls_duration, :integer
    add_column :tv_episodes, :hls_qualities, :text
  end
end
