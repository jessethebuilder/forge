class AccountsController < ApplicationController
  before_action :authenticate!, except: [:new, :create]
  before_action :authenticate_account_can_access_resource!, only: [:update, :edit]

  def new
    redirect_to '/account' if user_signed_in?
    @account = Account.new
    @account.users.build
    @account.credentials.build
  end

  def edit
    @account = current_account
    @menus = @account.menus
    @account.credentials.build
  end

  def show
    @account = current_account
    @menus = @account.menus
    @account.credentials.build
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      @user = @account.users.last
      sign_in(@user)
      redirect_to '/account', notice: 'Your Account has been created!'
    else
      render :new
    end
  end

  def update
    if @account.update(account_params)
    else
    end
  end

  private

  def account_params
    params.require(:account).permit(
      :contact_email, :contact_sms,
      credentials_attributes: [:username],
      users_attributes: [:email, :password]
    )
  end
end
