class MenusController < ApplicationController
  before_action :authenticate!
  before_action :set_menu, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy]
  before_action :set_depth, only: [:index, :show]
  before_action :set_scope, only: [:index, :show]

  def index
    @menus = Menu.send(@scope).where(account_id: current_account.id)
  end

  def show
    @deep = true if html_request? # View uses JSON template, so get the whole thing.
  end

  def create
    @menu = Menu.new(menu_params)
    @menu.account = current_account

    respond_to do |format|
      if @menu.save
        format.json { render :show, status: :created, location: @menu }
      else
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @menu.update(menu_params)
        format.json { render :show, status: :ok, location: @menu }
      else
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @menu.products.destroy_all if params[:destroy_products]
    @menu.groups.destroy_all if params[:destroy_groups]
    @menu.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
    @resource = @menu
  end

  def menu_params
    params.require(:menu).permit(
      :name, :description, :data, :reference, :active,
      :order, :contact_sms, :contact_email)
  end
end
