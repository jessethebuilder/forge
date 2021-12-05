class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :order
      t.jsonb :data, default: {}
      t.boolean :active, default: true
      t.boolean :archived, default: false

      t.timestamps
    end

    add_reference(:groups, :account, foreign_key: true)
    add_reference(:groups, :menu)
  end
end
