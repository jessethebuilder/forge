class ApplicationController < ActionController::Base
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
    # DEBUG - This is nothing, and must be implemented.
  end
end
