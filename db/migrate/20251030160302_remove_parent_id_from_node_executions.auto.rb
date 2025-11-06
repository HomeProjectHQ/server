# This migration comes from auto (originally 20251030000006)
class RemoveParentIdFromNodeExecutions < ActiveRecord::Migration[8.0]
  def change
    remove_column :auto_node_executions, :parent_id, :bigint
    remove_index :auto_node_executions, :parent_id if index_exists?(:auto_node_executions, :parent_id)
  end
end
