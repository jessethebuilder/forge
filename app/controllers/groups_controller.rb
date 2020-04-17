class GroupsController < ApplicationController
  include GroupsHelper
  before_action :authenticate!
  before_action :set_group, only: [:show, :update, :destroy, :edit]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]
  before_action :set_depth, only: [:index, :show], if: :json_request?
  before_action :set_scope, only: [:index, :show]

  def index
    @groups = Group.send(@scope)
                   .where(account_id: current_account.id)
                   .includes(:menu)
  end

  def show

  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(group_params)
    @group.account = current_account

    respond_to do |format|
      if @group.save
        format.html { redirect_to group_back_path(@group), notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to group_back_path(@group), notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group.products.destroy_all if params[:destroy_products]
    @group.destroy
    respond_to do |format|
      format.html { redirect_to group_back_path(@group), notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
    @resource = @group
  end

  def group_params
    params.require(:group).permit(
      :name, :description, :order, :data, :reference, :active, :menu_id)
  end
end
