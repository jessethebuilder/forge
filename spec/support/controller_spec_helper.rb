module ControllerSpecHelper
  def setup_controller_spec
    @account = create(:account)
    @credential = FactoryBot.create(:credential, account: @account)
  end

  def http_login
    token = @credential.token
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end
