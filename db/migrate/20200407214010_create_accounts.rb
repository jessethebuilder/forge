class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.boolean :active, default: true
      t.jsonb :data, default: {}
      t.string :sms
      t.string :email
      t.integer :sms_after_unseen, default: 0
      t.integer :email_after_unseen, default: 0

      t.timestamps
    end
  end
end
