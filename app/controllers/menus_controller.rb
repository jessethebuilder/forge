class MenusController < ApplicationController
  before_action :set_menu, only: [:show, :update, :destroy, :edit]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]

  def index
    @menus = Menu.where(account_id: current_account.id)
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
        format.html { redirect_to @menu, notice: 'Menu was successfully created.' }
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
        format.html { redirect_to @menu, notice: 'Menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @menu }
      else
        format.html { render :edit }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
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
