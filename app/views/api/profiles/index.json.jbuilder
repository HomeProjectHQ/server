json.profiles do
  json.array! @profiles do |profile|
    json.partial! 'api/profiles/profile', profile: profile
  end
end


