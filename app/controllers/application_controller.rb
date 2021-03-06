class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first
  end

  def require_authentication
    should_redirect = !current_user
    redirect_to '/login' if should_redirect
    should_redirect
  end

  def require_admin
    require_authentication and return
    is_admin = Admins.verify?(current_user.github_id)
    fail UnauthorizedError, 'must be an admin' unless is_admin
    is_admin
  end

  rescue_from UnauthorizedError do |error|
    flash[:error] = error.message || "Unauthorized"
    redirect_to '/'
  end
end
