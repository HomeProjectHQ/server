json.profiles do
  json.array! @profiles do |profile|
    json.partial! 'api/admin/profiles/profile', profile: profile, with_stats: true
  end
end

json.page @page
json.per_page @per_page
json.total @total
