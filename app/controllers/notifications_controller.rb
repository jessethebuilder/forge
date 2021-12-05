class NotificationsController < ApplicationController
  before_action :authenticate!
  before_action :set_order

  def index # TODO scope on no_type and spec

    @notifications = Notification.where(account_id: current_account.id)
                                       .page(params[:page]).per(100)
  end

  def create
    @notification = Notification.new(
      notification_params.merge(
        account: current_account
      )
    )

    respond_to do |format|
      if @notification.save
        # format.html { redirect_to @notification, notice: "Order notification was successfully created." }
        format.json { render :show, status: :created, location: @notification }
      else
        # format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def notification_params
    params.require(:notification).permit(
      :message, :account_id, :message_type
    )
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
