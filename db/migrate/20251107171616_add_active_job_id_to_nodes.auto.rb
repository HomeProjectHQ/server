# frozen_string_literal: true

# This migration comes from auto (originally 20251107000001)
# Add active_job_id to nodes for tracking ActiveJob instances
# This allows querying SolidQueue for the actual job status
class AddActiveJobIdToNodes < ActiveRecord::Migration[8.0]
  def change
    add_column :auto_nodes, :active_job_id, :string
    add_index :auto_nodes, :active_job_id
  end
end

