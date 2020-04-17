module ControllerSpecHelper
  def setup_controller_spec
    @account = create(:account)
    @user = FactoryBot.create(:user, account: @account)
    sign_in_user
  end

  def sign_in_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    # @user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
    sign_in @user
  end
end
