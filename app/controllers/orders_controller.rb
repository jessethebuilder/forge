class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]
  before_action :set_scope, only: [:index]

  def index
    @orders = Order.where(account_id: current_account.id)
                   .send(@scope)
                   .order(created_at: :desc)
                   .includes(:order_items)
  end

  def show
  end

  def create
    @order = Order.new(order_params)
    @order.account = current_account

    if @order.save
      NewOrderNotificationJob.perform_async(@order.id)
      payment_processor.charge(@order)
      render :show, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end


  def update
    if @order.update(order_params)
      render :show, status: :ok, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    head :no_content
  end

  private

  def set_order
    @order = Order.find(params[:id])
    @resource = @order
  end

  def order_params
    p = params.require(:order).permit(
      :note,
      :customer_id,
      :menu_id,
      :reference,
      :data,
      :active,
      :tip,
      :tax,
      items: [:product_id, :note, :amount]    )
    # Move :items to :order_items_attributes to make the API cleaner, but still
    # conforms to the Rails conventions.
    p[:order_items_attributes] = p[:items] if p[:items]
    p.delete(:items)

    return p
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new
  end
end
