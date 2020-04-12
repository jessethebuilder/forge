class CreateMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :menus do |t|
      t.string :name
      t.text :description
      t.string :reference
      t.jsonb :data, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference(:menus, :account, foreign_key: true)
  end
end
