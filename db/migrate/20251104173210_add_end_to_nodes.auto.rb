# frozen_string_literal: true

# This migration comes from auto (originally 20251104000009)
class AddEndToNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :auto_nodes, :end, :boolean, default: false, null: false
    add_index :auto_nodes, :end
  end
end

