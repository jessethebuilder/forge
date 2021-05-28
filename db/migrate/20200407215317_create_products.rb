class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.integer :price
      t.jsonb :data, default: {}
      t.boolean :active, default: true
      t.boolean :archived, default: false

      t.timestamps
    end

    add_reference(:products, :account, foreign_key: true)
    add_reference(:products, :menu)
    add_reference(:products, :group)
  end
end
