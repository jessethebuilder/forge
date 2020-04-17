class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.boolean :active, default: true
      t.jsonb :data, default: {}
      t.string :schema, default: 'menu'

      t.timestamps
    end
  end
end
