class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]
  before_action :set_scope, only: [:index]
  skip_before_action :verify_authenticity_token, if: :json_request?
  respond_to :html, :json, :js

  def broadcast_order!
    ActionCable.server.broadcast(
      "orders_for_account_#{@order.account.id}",
      {
        action: 'new_order',
        data: {
          order_id: @order.id
        }
      }
    )
  end


  def create
    @order = Order.new(order_params)
    @order.account = current_account

    respond_to do |format|
      if @order.save
        broadcast_order!
        NewOrderNotificationJob.perform_async(@order.id)
        payment_processor.charge(@order)

        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @orders = Order.where(account_id: current_account.id)
                   .send(@scope)
                   .order(created_at: :desc)
                   .includes(:order_items)
  end

  def show
    update_seen if html_request?
  end


  # Doing orders from an HTML admin panel is an intereting idea. But not for now.
  # def new
  #   @order = Order.new
  # end
  #
  # def edit
  # end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to '/orders' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
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

  def update_seen
    @order.update(seen: true) unless @order.seen?
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new
  end
end
