class CreateMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :menus do |t|
      t.string :name
      t.text :description
      t.jsonb :data, default: {}
      t.boolean :active, default: true
      t.boolean :archived, default: false
      t.string :sms
      t.string :email

      t.timestamps
    end

    add_reference(:menus, :account, foreign_key: true)
  end
end
