class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.boolean :active, default: true
      t.jsonb :data, default: {}
      t.string :contact_sms
      t.string :contact_email
      t.integer :contact_sms_after_unseen, default: 0
      t.integer :contact_email_after_unseen, default: 0

      t.timestamps
    end
  end
end
