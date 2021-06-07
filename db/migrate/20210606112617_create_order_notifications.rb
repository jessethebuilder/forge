class CreateOrderNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :order_notifications do |t|
      t.text :message
      t.string :message_type
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
