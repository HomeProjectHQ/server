# This migration comes from auto (originally 20251031000003)
class AddNextNodeIdToNodeExecutions < ActiveRecord::Migration[8.0]
  def change
    add_column :auto_node_executions, :next_node_id, :string
    add_index :auto_node_executions, :next_node_id
    add_index :auto_node_executions, [:execution_id, :next_node_id]
  end
end

