class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.string :reference
      t.jsonb :data, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference(:groups, :account, foreign_key: true)
    add_reference(:groups, :menu, foreign_key: true)
  end
end
