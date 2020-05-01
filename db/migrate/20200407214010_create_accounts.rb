class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.boolean :active, default: true
      t.jsonb :data, default: {}
      t.string :contact_sms
      t.string :contact_email
      t.boolean :always_contact, default: true
      t.integer :contact_after, default: 15

      t.timestamps
    end
  end
end
