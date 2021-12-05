class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.text :message
      t.string :subject
      t.string :notification_type

      t.timestamps
    end

    add_reference(:notifications, :order, foreign_key: true)
  end
end
