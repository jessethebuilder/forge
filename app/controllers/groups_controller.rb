class GroupsController < ApplicationController
  before_action :authenticate!
  before_action :set_group, only: [:show, :update, :destroy]
  before_action :authenticate_account_can_access_resource!, only: [:show, :update, :destroy, :edit]
  before_action :set_depth, only: [:index, :show]
  before_action :set_scope, only: [:index, :show]

  def index
    @groups = Group.send(@scope)
                   .where(account_id: current_account.id)
                   .includes(:menu)
  end

  def show
  end

  def create
    @group = Group.new(group_params)
    @group.account = current_account

    if @group.save
      render :show, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def update
    if @group.update(group_params)
      render :show, status: :ok, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group.products.destroy_all if params[:destroy_products]
    @group.destroy
    head :no_content
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
