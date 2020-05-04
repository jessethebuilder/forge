class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.jsonb :data, default: {}
      t.string :reference
      t.string :note
      t.float :tip, default: 0.0
      t.float :tax, default: 0.0
      t.boolean :active, default: true
      t.boolean :seen, default: false

      t.timestamps
    end

    add_reference(:orders, :account, foreign_key: true)
    add_reference(:orders, :menu)
    add_reference(:orders, :customer)
  end
end
