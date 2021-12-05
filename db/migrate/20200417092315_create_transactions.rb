class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.integer :amount
      t.string :stripe_id
      
      t.timestamps
    end

    add_reference(:transactions, :order, foreign_key: true)
  end
end
