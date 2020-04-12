class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.float :price
      t.jsonb :data, default: {}
      t.string :reference
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference(:products, :account, foreign_key: true)
    add_reference(:products, :menu, foreign_key: true)
    add_reference(:products, :group, foreign_key: true)
  end
end
