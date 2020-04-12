class ApplicationController < ActionController::Base
 include ActionController::HttpAuthentication::Token::ControllerMethods
 before_action :authenticate!

  def auth_resource_account(resource)
    unless current_account == resource.account
      respond_to do |format|
        format.json{
          render json: {
            error: t('errors.no_auth.resource', resource_type: resource.class.name)
          },
          status: 401
        }
      end
    end
  end

  def current_account
    @current_account
  end

  protected

  def authenticate!
    if request.format == :json
      authenticate_api_account!
    else
    end
  end

  def authenticate_api_account!
    authenticate_api_token || render_api_unauthorized
  end

  def authenticate_api_token
    authenticate_with_http_token do |token, options|
      @current_account = Credential.find_by(token: token).account
    end
  end

  def render_api_unauthorized(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm}")
    render json: 'Bad credentials', status: :unauthorized
  end
end
