json.tv_shows do
  json.array! @tv_shows do |tv_show|
    json.partial! 'api/tv_shows/tv_show', tv_show: tv_show
  end
end

json.page @page
json.per_page @per_page
json.total @total


