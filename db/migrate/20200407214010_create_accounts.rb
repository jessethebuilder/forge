class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.boolean :active, default: true
      t.jsonb :data, default: {}
      t.string :sms
      t.string :email
      t.string :stripe_key
      t.string :stripe_secret

      t.timestamps
    end
  end
end
