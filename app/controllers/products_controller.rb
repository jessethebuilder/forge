class ProductsController < ApplicationController
  include ProductsHelper
  before_action :authenticate!
  before_action :set_product, only: [:show, :update, :destroy, :edit]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]
  before_action :set_scope, only: [:index, :show]
  before_action :authenticate_schema!, only: [:index], if: :html_request?

  def index
      @products = Product.send(@scope)
                         .where(account_id: current_account.id)
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
        format.html { redirect_to product_back_path(@product), notice: 'Product was successfully created.' }
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
        format.html { redirect_to product_back_path(@product), notice: 'Product was successfully updated.' }
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
      format.html { redirect_to product_back_path(@product), notice: 'Product was successfully destroyed.' }
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

  def set_menus
    @menus = current_account.menus
  end

  def set_groups
    @groups = current_account.groups
  end
end
