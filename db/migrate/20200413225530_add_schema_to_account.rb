class AddSchemaToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :schema, :string, default: 'menu'
  end
end
