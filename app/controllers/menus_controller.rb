class MenusController < ApplicationController
  before_action :authenticate!
  before_action :set_menu, only: [:show, :update, :destroy, :edit]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]
  before_action :set_depth, only: [:index, :show], if: :json_request?
  before_action :set_scope, only: [:index, :show]
  before_action :authenticate_schema!, only: [:index], if: :html_request?

  def index
    @menus = Menu.send(@scope).where(account_id: current_account.id)
  end

  def show
  end


  def new
    @menu = Menu.new
  end

  def edit
  end

  def create
    @menu = Menu.new(menu_params)
    @menu.account = current_account

    respond_to do |format|
      if @menu.save
        format.html { redirect_to edit_menu_path(@menu), notice: 'Menu was successfully created.' }
        format.json { render :show, status: :created, location: @menu }
      else
        format.html { render :new }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @menu.update(menu_params)
        format.html { redirect_to edit_menu_path(@menu), notice: 'Menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @menu }
      else
        format.html { render :edit }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @menu.products.destroy_all if params[:destroy_products]
    @menu.groups.destroy_all if params[:destroy_groups]
    @menu.destroy

    respond_to do |format|
      format.html { redirect_to menus_url, notice: 'Menu was successfully destroyed.' }
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
      :name, :description, :data, :reference, :active, :order)
  end
end
