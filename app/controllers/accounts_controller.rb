class AccountsController < ApplicationController
  before_action :authenticate!, except: [:new]

  def new
    redirect_to '/account' if user_signed_in?
  end

  def show
    @account = current_account
    @menus = @account.menus
  end
end
