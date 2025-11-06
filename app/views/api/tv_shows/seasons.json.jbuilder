json.tv_show do
  json.extract! @tv_show, :id, :title
end

json.seasons do
  json.array! @seasons do |season|
    json.partial! 'api/tv_shows/season', season: season
  end
end

