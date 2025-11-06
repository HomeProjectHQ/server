# This migration comes from auto (originally 20251029000004)
class CleanupNodeExecutionColumns < ActiveRecord::Migration[8.0]
  def change
    # Remove resolved_parameters and raw_result - not needed
    remove_column :auto_node_executions, :resolved_parameters, :json
    remove_column :auto_node_executions, :raw_result, :json
    
    # Change selection from enum to string - jobs decide selection names, not schema
    change_column :auto_node_executions, :selection, :string
  end
end

