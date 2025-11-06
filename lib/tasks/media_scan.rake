namespace :media do
  desc "Scan /Users/Shared/nfs/media for movies, TV shows, and music"
  task scan: :environment do
    media_root = ENV.fetch('MEDIA_ROOT', '/Users/Shared/nfs/media')
    
    puts "=" * 60
    puts "Starting Media Library Scan"
    puts "=" * 60
    puts "Media root: #{media_root}"
    puts ""
    
    unless Dir.exist?(media_root)
      puts "ERROR: Media root directory not found: #{media_root}"
      puts "Set MEDIA_ROOT environment variable to specify a different location:"
      puts "  rake media:scan MEDIA_ROOT=/path/to/media"
      exit 1
    end
    
    # Check for TMDB API key
    # (Key can be set via ENV var or in config/initializers/tmdb.rb)
    if ENV['TMDB_API_KEY'].present?
      puts "✓ TMDB API key found (from environment variable)"
    else
      puts "✓ Using TMDB API key from initializer"
    end
    puts ""
    
    # Queue the scan job
    MediaScannerJob.perform_later(media_root)
    
    puts "Media scan job queued!"
    puts ""
    puts "The scan will:"
    puts "  • Find all video files in #{media_root}/Movies"
    puts "  • Find all TV episodes in #{media_root}/TV"
    puts "  • Find all music files in #{media_root}/Music"
    puts "  • Fetch metadata from TMDB for movies and TV shows"
    puts "  • Create database records for all media"
    puts ""
    puts "Monitor progress with:"
    puts "  tail -f log/development.log"
    puts ""
    puts "Make sure the job processor is running:"
    puts "  bin/jobs"
    puts "=" * 60
  end
  
  desc "Show media library statistics"
  task stats: :environment do
    puts "=" * 60
    puts "Media Library Statistics"
    puts "=" * 60
    puts ""
    puts "Movies:      #{Movie.count}"
    puts "TV Shows:    #{TvShow.count}"
    puts "  Seasons:   #{TvSeason.count}"
    puts "  Episodes:  #{TvEpisode.count}"
    puts "Artists:     #{Artist.count}"
    puts "Albums:      #{Album.count}"
    puts "Songs:       #{Song.count}"
    puts ""
    puts "Users:       #{User.count}"
    puts "=" * 60
  end
  
  desc "Clear all media from database (keeps files intact)"
  task clear: :environment do
    puts "WARNING: This will delete all media records from the database!"
    puts "Files will NOT be deleted from disk."
    print "Are you sure? (yes/no): "
    
    response = STDIN.gets.chomp
    
    if response.downcase == 'yes'
      puts "Clearing media library..."
      
      Movie.destroy_all
      TvShow.destroy_all  # Cascades to seasons and episodes
      Artist.destroy_all  # Cascades to albums and songs
      
      puts "Media library cleared!"
    else
      puts "Cancelled."
    end
  end
end

