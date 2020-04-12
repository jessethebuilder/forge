class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]

  def index
    @customers = Customer.where(account_id: current_account.id)
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def edit
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.account = current_account

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
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
