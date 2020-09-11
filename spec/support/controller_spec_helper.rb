module ControllerSpecHelper
  def setup_controller_spec
    @account = create(:account)
    @user = FactoryBot.create(:user, account: @account)
    @credential = FactoryBot.create(:credential, account: @account, user: @user)
    sign_in_user
  end

  def sign_in_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @user
  end

  def http_login
    token = @credential.token
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(token)
  end
end
