class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.float :amount
      t.jsonb :data, default: {}
      t.string :note
      t.references :orders, null: false, foreign_key: true
      t.references :products, null: false, foreign_key: true

      t.timestamps
    end

    add_reference(:order_items, :order, foreign_key: true)
    add_reference(:order_items, :product, foreign_key: true)
  end
end
