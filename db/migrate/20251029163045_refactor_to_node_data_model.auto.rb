# This migration comes from auto (originally 20251029000003)
class RefactorToNodeDataModel < ActiveRecord::Migration[8.0]
  def change
    # Add data column to node_executions (replaces result and becomes namespace)
    add_column :auto_node_executions, :data, :json
    
    # Remove context from executions (no longer needed - data lives on nodes)
    remove_column :auto_executions, :context, :json
    remove_column :auto_executions, :current_node_id, :string
    
    # Remove old columns from node_executions that are no longer needed
    remove_column :auto_node_executions, :result, :json
    remove_column :auto_node_executions, :resolved_result, :json
  end
end

