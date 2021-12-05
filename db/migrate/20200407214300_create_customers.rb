class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.jsonb :data, default: {}
      t.string :stripe_id

      t.timestamps
    end

    add_reference(:customers, :account, foreign_key: true)
  end
end
