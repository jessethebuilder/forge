class OrderNotificationsController < ApplicationController
  before_action :authenticate!
  before_action :set_order

  def index
    @order_notifications = OrderNotification.where(account_id: current_account.id)
                                            .page(params[:page]).per(100)
  end

  def create
    @order_notification = OrderNotification.new(
      order_notification_params.merge(
        account: current_account
      )
    )

    respond_to do |format|
      if @order_notification.save
        # format.html { redirect_to @order_notification, notice: "Order notification was successfully created." }
        format.json { render :show, status: :created, location: @order_notification }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order_notification.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def order_notification_params
    params.require(:order_notification).permit(
      :message, :account_id, :message_type
    )
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
