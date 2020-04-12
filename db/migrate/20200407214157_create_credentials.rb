class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      t.string :token
      t.string :username

      t.timestamps
    end

    add_reference(:credentials, :account, foreign_key: true)
  end
end
