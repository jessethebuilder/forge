class ProductsController < ApplicationController
  before_action :authenticate!
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]
  before_action :set_scope, only: [:index, :show]

  def index
    @products = Product.send(@scope)
                       .where(account_id: current_account.id)
                       .includes(:menu)
                       .includes(:group)
  end

  def show
  end

  def create
    @product = Product.new(product_params.merge(account: current_account))

    if @product.save
      render :show, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render :show, status: :ok, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
    @resource = @product
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :data, :active,
      :order, :menu_id, :group_id)
  end

  def set_menus
    @menus = current_account.menus
  end

  def set_groups
    @groups = current_account.groups
  end
end
