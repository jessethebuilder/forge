class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  # , if: :json_request?

  RECORD_SCOPES = %w|all active inactive|

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
    # Refers to whether the data returned include associated record data.
    @deep = params[:deep] ? true : false
  end

  def set_scope
    @scope = :active
    @scope = params[:scope] if RECORD_SCOPES.include?(params[:scope])
  end

  # def html_request?
  # html requests are no longer allowed. They may be useful for administrative
  # purposes, or managing tokens, but user menu ineractions should be moved to
  # client apps.
  #   request.format == :html
  # end

  def json_request?
    # byebug
    request.format == :json
  end

  def authenticate!(*params)
    if request.format == :json
      authenticate_api_account!
    else
      raise StandardError, 'WWW Not Implemented'
      # authenticate_web_user!
    end
  end

  # def authenticate_web_user!
  #   authenticate_user!
  #   @current_account = current_user.account
  # end

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
