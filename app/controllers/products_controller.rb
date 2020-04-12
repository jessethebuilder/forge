class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]

  def index
    @products = Product.where(account_id: current_account.id)
                       .includes(:menu)
                       .includes(:group)
  end

  def show
  end


  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.account = current_account

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
    @resource = @product
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :data, :reference, :active,
      :order, :menu_id, :group_id)
  end
end
