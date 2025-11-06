# frozen_string_literal: true

# This migration comes from auto (originally 20251105030001)
# Refactor to Nested Workflows Architecture
# 
# Key Changes:
# 1. Workflows can have parent workflows (for tracking child workflows)
# 2. Workflows store their input args (passed from fork nodes)
# 3. Nodes are purely linear - no branch_index needed
# 4. Fork nodes create child workflows and wait for completion
# 5. No DAG/edges needed - workflows are simple chains
#
# Architecture:
#   Parent Workflow:
#     node → node → fork_node (creates children, stays active) → node
#                       ↓
#   Child Workflows (created by fork):
#     Workflow 1: node → node → node (linear)
#     Workflow 2: node → node → node (linear)
#     Workflow 3: node → node → node (linear)
#
class RefactorToNestedWorkflows < ActiveRecord::Migration[8.0]
  def change
    # Add parent tracking to workflows (optional, just for visibility)
    unless column_exists?(:auto_workflows, :parent_workflow_id)
      add_column :auto_workflows, :parent_workflow_id, :bigint
      add_index :auto_workflows, :parent_workflow_id
    end
    
    # Add workflow args storage (JSON column for input parameters)
    unless column_exists?(:auto_workflows, :args)
      add_column :auto_workflows, :args, :jsonb, default: {}, null: false
      add_index :auto_workflows, :args, using: :gin
    end
    
    # Remove branch_index from nodes (no longer needed with fork model)
    remove_column :auto_nodes, :branch_index, :integer if column_exists?(:auto_nodes, :branch_index)
    
    # Remove parent_node_id (nodes are linear, determined by YAML next field)
    remove_column :auto_nodes, :parent_node_id, :bigint if column_exists?(:auto_nodes, :parent_node_id)
    
    puts "✓ Refactored to nested workflows architecture"
    puts "✓ Workflows can have parents (optional tracking)"
    puts "✓ Workflows store args (input parameters)"
    puts "✓ Nodes are purely linear (no branches)"
    puts "✓ Fork nodes create & wait for child workflows"
  end
end

