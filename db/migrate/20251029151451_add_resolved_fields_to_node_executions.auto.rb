# This migration comes from auto (originally 20251029000002)
class AddResolvedFieldsToNodeExecutions < ActiveRecord::Migration[8.0]
  def change
    add_column :auto_node_executions, :resolved_parameters, :json
    add_column :auto_node_executions, :raw_result, :json
    add_column :auto_node_executions, :resolved_result, :json
  end
end

