json.jobs do
  json.pending @jobs[:pending]
  json.completed @jobs[:completed]
  json.failed @jobs[:failed]
end

json.recent_jobs do
  json.array! @recent_jobs do |job|
    json.extract! job, :id, :class_name, :status, :created_at, :finished_at
  end
end


