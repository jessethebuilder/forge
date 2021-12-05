class TransactionsController < ApplicationController
  before_action :authenticate!
  before_action :set_order

  def create
    @transaction = Transaction.new(transaction_params.merge(
        order: @order
      )
    )

    respond_to do |format|
      if @transaction.save
        format.json { render 'transactions/show', status: :created, transaction: @transaction }
      else
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end
  private

  def transaction_params
    params.require(:transaction).permit(
      :amount, :card_number, :card_expiration, :card_ccv, :stripe_token
    )
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
