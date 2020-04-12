class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.jsonb :data, default: {}
      t.string :reference
      t.string :note

      t.timestamps
    end

    add_reference(:orders, :account, foreign_key: true)
    add_reference(:orders, :menu, foreign_key: true)
    add_reference(:orders, :customer, foreign_key: true)
  end
end
