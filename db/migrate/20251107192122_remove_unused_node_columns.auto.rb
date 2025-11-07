# frozen_string_literal: true

# This migration comes from auto (originally 20251107000004)
# Remove unused columns from nodes table
# Storage reduction: 6 columns removed
#
# Removed columns and why:
# - job_id: Redundant with active_job_id (can query SolidQueue by active_job_id)
# - node_index: Can be computed from parent chain traversal
# - depth: Not used, can be computed from parent chain if needed
# - completed_at: Redundant with child_id presence (has child = transitioned)
# - started_at: Can use SolidQueue::Job.created_at instead
# - job_class: Never used
class RemoveUnusedNodeColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :auto_nodes, :job_id, :bigint
    remove_column :auto_nodes, :node_index, :integer
    remove_column :auto_nodes, :depth, :integer
    remove_column :auto_nodes, :completed_at, :datetime
    remove_column :auto_nodes, :started_at, :datetime
    remove_column :auto_nodes, :job_class, :string
    
    # Remove the old unique index on workflow_id + node_index
    remove_index :auto_nodes, name: :index_auto_nodes_on_workflow_id_and_node_index, if_exists: true
    
    puts "✓ Removed 6 unused columns from auto_nodes"
    puts "✓ Storage reduction: ~50 bytes per node"
  end
end

