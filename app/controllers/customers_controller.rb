class CustomersController < ApplicationController
  before_action :authenticate!
  before_action :set_customer, only: [:show, :update, :destroy, :edit]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]

  def index
    @customers = Customer.where(account_id: current_account.id)
  end

  def show
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.account = current_account

    respond_to do |format|
      if @customer.save
        format.json { render :show, status: :created, location: @customer }
      else
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.json { render :show, status: :ok, location: @customer }
      else
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
    @resource = @customer
  end

  def customer_params
    params.require(:customer).permit(
      :name, :email, :phone, :data, :reference)
  end
end
