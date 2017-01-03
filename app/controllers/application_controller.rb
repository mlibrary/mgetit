class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token, only: [:redirect]

  def redirect
    if request.query_parameters.empty?
      redirect_to '/citation-linker/', status: 302
    elsif params.has_key?('SS_Page') && params['SS_Page'] == 'refiner'
      redirect_to '/citation-linker/', status: 302
    else
      redirect_to(url_for(controller: 'resolve', action: 'index') + '?' + request.query_string, status: 302)
    end
  end
end
