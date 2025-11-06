# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default media folder if it doesn't exist
media_path = "/Users/Shared/nfs/media"

if File.directory?(media_path)
  unless MediaFolder.exists?(path: media_path)
    begin
      media_folder = MediaFolder.create!(
        name: "Primary Media",
        path: media_path,
        enabled: true
      )
      puts "✅ Created media folder: #{media_folder.name} at #{media_folder.path}"
      puts "   Available media types: #{media_folder.available_media_types.join(', ')}"
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Could not create media folder: #{e.message}"
      puts "   Make sure #{media_path} contains at least one of: TV, Movies, Music"
    end
  else
    puts "ℹ️  Media folder already exists: #{media_path}"
  end
else
  puts "⚠️  Path does not exist: #{media_path}"
  puts "   Skipping media folder creation"
  puts "   Create the path and ensure it contains subdirectories: TV, Movies, and/or Music"
end

puts "\n📁 Current media folders:"
if MediaFolder.any?
  MediaFolder.all.each do |media_folder|
    puts "  #{media_folder.name} (#{media_folder.path})"
    puts "    Available: #{media_folder.available_media_types.join(', ')}"
    puts "    Enabled: #{media_folder.enabled}"
  end
else
  puts "  No media folders configured yet"
end
