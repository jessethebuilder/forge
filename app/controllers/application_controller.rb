class ApplicationController < ActionController::Base
  # Need method to prevent scopes from going to Index pages when they should go to menus/show or groups/show
  # Should just bounce them back to root, as those routes would only be discovered by
  # typing in.
  RECORD_SCOPES = %w|all active|

  protected

  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_account_can_access_resource!
    unless current_account == @resource.account
      respond_to do |format|
        format.json{
          render json: {
            error: t('errors.no_auth.resource', resource_type: @resource.class.name)
          },
          status: 401
        }
      end
    end
  end

  def current_account
    @current_account
  end

  def set_depth
    @deep = params[:deep] ? true : false
  end

  def set_scope
    @scope = :active
    @scope = params[:scope] if RECORD_SCOPES.include?(params[:scope])
  end



  def json_request?
    request.format == :json
  end

  def authenticate!(*params)
    if request.format == :json
      authenticate_api_account!
    else
      authenticate_web_user
    end
  end

  def authenticate_web_user
    authenticate_user!
    @current_account = current_user.account
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
