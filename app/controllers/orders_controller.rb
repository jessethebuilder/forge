class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_order, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]

  def index
    @orders = Order.where(account_id: current_account.id)
                   .where(order_search)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(params[:per_page] || 100)
                   .includes(:order_items)
                   .includes(:menu)
  end

  def show
  end

  def create
    @order = Order.new(order_params.merge(account_id: current_account.id))

    respond_to do |format|
      if @order.save
        NewOrderNotificationJob.perform_async(@order.id) if params[:notify] == 'true'

        format.json { render :show, status: :created, location: @order }
      else
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
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
    p = params.require(:order).permit(
      :note,
      :customer_id,
      :menu_id,
      :data,
      :tip,
      :tax,
      :seen_at,
      :delivered_at,
      :see,
      order_items: [
        :product_id,
        :note,
        :amount
      ],
      transactions: [
        :amount,
        :card_number,
        :card_expiration,
        :card_ccv,
        :stripe_token
      ]
    )

    # Move :items to :order_items_attributes to make the API cleaner, but still
    # conforms to the Rails conventions.
    p[:order_items_attributes] = p[:order_items] if p[:order_items]
    p.delete(:order_items)

    p[:transactions_attributes] = p[:transactions] if p[:transactions]
    p.delete(:transactions)

    return p
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new
  end

  def order_search
    search = []

    q = params[:q]
    return search if q.nil?

    search << "orders.created_at >= '#{q[:created_after]}'" if q[:created_after]
    search << "orders.created_at <= '#{q[:created_before]}'" if q[:created_before]

    if q[:created_on]
      created_on = Date.parse(q[:created_on])
      search << "orders.created_at >= '#{created_on.beginning_of_day}'"
      search << "orders.created_at <= '#{created_on.end_of_day}'"
    end

    return search.join(' AND ')
  end
end
