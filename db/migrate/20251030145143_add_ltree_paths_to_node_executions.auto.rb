# This migration comes from auto (originally 20251030000005)
class AddLtreePathsToNodeExecutions < ActiveRecord::Migration[8.0]
  def change
    # Enable ltree extension
    enable_extension :ltree
    
    # Add path column
    add_column :auto_node_executions, :path, :ltree
    
    # Add GiST index for fast tree queries
    add_index :auto_node_executions, :path, using: :gist
  end
end

