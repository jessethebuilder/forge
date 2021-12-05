class MenusController < ApplicationController
  before_action :authenticate!
  before_action :set_menu, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]
  before_action :set_scope, only: [:index, :show]

  def index
    @menus = Menu.send(@scope).where(account_id: current_account.id)
  end

  def show
    @deep = true
  end

  def create
    @menu = Menu.new(menu_params)
    @menu.account = current_account

    if @menu.save
      render :show, status: :created, location: @menu
    else
      render json: @menu.errors, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(menu_params)
      render :show, status: :ok, location: @menu
    else
      render json: @menu.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.products.destroy_all if params[:destroy_products]
    @menu.groups.destroy_all if params[:destroy_groups]
    @menu.destroy
    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
    @resource = @menu
  end

  def menu_params
    params.require(:menu).permit(
      :name, :description, :data, :reference, :active,
      :order, :sms, :email)
  end
end
