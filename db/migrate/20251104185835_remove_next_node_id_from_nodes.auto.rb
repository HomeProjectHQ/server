# frozen_string_literal: true

# This migration comes from auto (originally 20251104000010)
class RemoveNextNodeIdFromNodes < ActiveRecord::Migration[7.1]
  def change
    remove_column :auto_nodes, :next_node_id, :string
  end
end

