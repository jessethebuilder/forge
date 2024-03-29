class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.jsonb :data, default: {}
      t.string :note
      t.integer :tip, default: 0.0
      t.integer :tax, default: 0.0
      t.datetime :seen_at
      t.datetime :delivered_at
      
      t.timestamps
    end

    add_reference(:orders, :account, foreign_key: true)
    add_reference(:orders, :menu)
    add_reference(:orders, :customer)
  end
end
