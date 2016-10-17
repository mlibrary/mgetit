class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def redirect
    if request.query_parameters.empty?
      redirect_to '/citation-linker/', status: 302
    else
      redirect_to request.query_parameters.merge({ controller: 'resolve', action: 'index', status: 302})
    end
  end
end
