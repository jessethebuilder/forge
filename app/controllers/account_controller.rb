class AccountController < ApplicationController
  def new
    @account = Account.new
  end
end
