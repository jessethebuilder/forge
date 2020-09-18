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

  def all_inactive
    # Includes Products in inactive Menus and Groups.
    @products = Product.inactive.to_a
    @products += Menu.inactive.map(&:products).flatten
    @products += Group.inactive.map(&:products).flatten

    render :index
  end

  def show
  end

  def create
    @product = Product.new(product_params)
    @product.account = current_account

    respond_to do |format|
      if @product.save
        format.json { render :show, status: :created, location: @product }
      else
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.json { render :show, status: :ok, location: @product }
      else
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
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
