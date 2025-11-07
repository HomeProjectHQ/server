# frozen_string_literal: true

# This migration comes from auto (originally 20251107000003)
# Fix foreign key constraints on nodes to allow cascade deletion
class FixNodeForeignKeysForCascade < ActiveRecord::Migration[8.0]
  def change
    # Remove old foreign keys (from previous migration)
    remove_foreign_key :auto_nodes, column: :parent_id if foreign_key_exists?(:auto_nodes, column: :parent_id)
    remove_foreign_key :auto_nodes, column: :child_id if foreign_key_exists?(:auto_nodes, column: :child_id)
    
    # Add them back with SET NULL on delete (nodes can exist without parent/child)
    add_foreign_key :auto_nodes, :auto_nodes, column: :parent_id, on_delete: :nullify
    add_foreign_key :auto_nodes, :auto_nodes, column: :child_id, on_delete: :nullify
    
    puts "✓ Updated node foreign keys to SET NULL on delete"
  end
end

