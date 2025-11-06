json.extract! season, :id, :season_number, :name, :air_date

json.episode_count season.tv_episodes.count
json.poster_url season.poster_path ? "https://image.tmdb.org/t/p/w500#{season.poster_path}" : nil

