class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.float :amount
      t.string :reference 

      t.timestamps
    end

    add_reference(:transactions, :order)
  end
end
