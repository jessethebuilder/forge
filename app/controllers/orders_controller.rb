class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]

  def create
    @order = Order.new(order_params)
    @order.account = current_account

    respond_to do |format|
      if @order.save
        NewOrderNotificationJob.perform_async(@order.id) if params[:notify] == 'true'

        payment_processor.charge(@order)

        format.json { render :show, status: :created, location: @order }
      else
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    search = order_search(params[:q])

    @orders = Order.where(account_id: current_account.id)
                   .where(search)
                   .order(created_at: :desc)
                   .includes(:order_items)
                   .includes(:menu)
  end

  def show
  end


  def update
    respond_to do |format|
      if @order.update(order_params)
        format.json { render :show, status: :ok, location: @order }
      else
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
    @resource = @order
  end

  def order_params
    params.require(:order).permit(
      :note,
      :customer_id,
      :menu_id,
      :reference,
      :data,
      :active,
      :tip,
      :tax,
      order_items: [:product_id, :note, :amount]
    )
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new
  end

  def order_search(q)
    search = {}

    q[:created_before] = q[:created_before] if q[:created_before]
    q[:created_after] = q[:created_after] if q[:created_after]

    if ( created_on = Date.parse(q[:created_on]) )
      q[:created_after] = created_on.beginning_of_day
      q[:created_before] = created_on.end_of_day
    end

    return search
  end
end
