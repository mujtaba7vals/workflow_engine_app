class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :scope_current_company
  before_action :authenticate_user!

  UNWANTED_BASE_PATHS = [
    '/users/sign_out'
  ].freeze

  UNWANTED_SUBDOMAIN_PATHS = [
    '/users/sign_up'
  ].freeze

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  protected

  # Check if the given path is in the manually blocked lists, in subdomains or without subdomains
  def path_blocked?(path, request_type = :base)
    if request_type == :base
      UNWANTED_BASE_PATHS.include? path
    elsif request_type == :subdomain
      UNWANTED_SUBDOMAIN_PATHS.include? path
    end
  end
  helper_method :path_blocked?

  # Check if the given path is manually blocked from the current request location
  def path_blocked_from_location?(path, request)
    request_type = request.subdomain.present? ? :subdomain : :base
    path_blocked?(path, request_type)
  end
  helper_method :path_blocked_from_location?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, company_attributes: [:name, :subdomain]])
  end

  def current_company
    Company.find_by_subdomain! request.subdomain if request.subdomain.present?
  end
  helper_method :current_company

  def scope_current_company
    company = current_company
    p company
    Company.current_id = company ? current_company.id : nil
    yield
  ensure
    Company.current_id = nil
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
