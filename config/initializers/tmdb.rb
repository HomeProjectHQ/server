# TMDB API Configuration
# Get your API key from: https://www.themoviedb.org/settings/api

Tmdb::Api.key(ENV.fetch('TMDB_API_KEY'))
Tmdb::Api.language('en')

