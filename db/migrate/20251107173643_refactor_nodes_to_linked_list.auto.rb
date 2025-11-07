# frozen_string_literal: true

# This migration comes from auto (originally 20251107000002)
# Refactor nodes to use linked list (parent/child) instead of status enum
# 
# Key Benefits:
# 1. Leaf nodes are simply: child_id IS NULL
# 2. Nodes needing transition: completed (SolidQueue) + child_id IS NULL + end != true
# 3. Workflow completion: end = true + child_id IS NULL + completed
# 4. No more status column - all state derived from SolidQueue + structure
#
class RefactorNodesToLinkedList < ActiveRecord::Migration[8.0]
  def change
    # Add parent/child relationship columns
    add_column :auto_nodes, :parent_id, :bigint
    add_column :auto_nodes, :child_id, :bigint
    
    # Add indexes for efficient queries
    add_index :auto_nodes, :parent_id
    add_index :auto_nodes, :child_id
    add_index :auto_nodes, [:workflow_id, :child_id]  # For finding leaves per workflow
    
    # Add foreign key constraints
    add_foreign_key :auto_nodes, :auto_nodes, column: :parent_id
    add_foreign_key :auto_nodes, :auto_nodes, column: :child_id
    
    # Drop the old status column - all state is now in SolidQueue + structure
    remove_column :auto_nodes, :status, :integer
    
    puts "✓ Refactored nodes to linked list structure"
    puts "✓ Added parent_id and child_id columns"
    puts "✓ Dropped status column (using SolidQueue-based status)"
  end
end

