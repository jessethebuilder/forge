class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :email
      t.string :name
      t.string :phone
      t.string :reference
      t.jsonb :data, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference(:customers, :account, foreign_key: true)
  end
end
