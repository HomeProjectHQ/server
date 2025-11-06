# frozen_string_literal: true

# This migration comes from auto (originally 20251104000008)
class RenameExecutionToWorkflow < ActiveRecord::Migration[7.1]
  def change
    # Rename tables
    rename_table :auto_executions, :auto_workflows
    rename_table :auto_node_executions, :auto_nodes
    
    # Rename foreign key column
    rename_column :auto_nodes, :execution_id, :workflow_id
    
    # Update indexes
    # The old index on execution_id will be automatically renamed by Rails
    # But we should ensure the new name is correct
    if index_exists?(:auto_nodes, :workflow_id, name: 'index_auto_node_executions_on_execution_id')
      rename_index :auto_nodes, 'index_auto_node_executions_on_execution_id', 'index_auto_nodes_on_workflow_id'
    end
    
    # Rename unique index on node_index
    if index_exists?(:auto_nodes, [:workflow_id, :node_index], name: 'index_auto_node_executions_on_execution_id_and_node_index')
      rename_index :auto_nodes, 'index_auto_node_executions_on_execution_id_and_node_index', 'index_auto_nodes_on_workflow_id_and_node_index'
    end
    
    # Rename path index
    if index_exists?(:auto_nodes, :path, name: 'index_auto_node_executions_on_path', using: :gist)
      rename_index :auto_nodes, 'index_auto_node_executions_on_path', 'index_auto_nodes_on_path'
    end
    
    # Rename job_id index
    if index_exists?(:auto_nodes, :job_id, name: 'index_auto_node_executions_on_job_id')
      rename_index :auto_nodes, 'index_auto_node_executions_on_job_id', 'index_auto_nodes_on_job_id'
    end
    
    # Rename status index
    if index_exists?(:auto_nodes, :status, name: 'index_auto_node_executions_on_status')
      rename_index :auto_nodes, 'index_auto_node_executions_on_status', 'index_auto_nodes_on_status'
    end
  end
end

