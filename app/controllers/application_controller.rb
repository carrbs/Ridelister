class ApplicationController < ActionController::API
  def not_found
    render json: { error: 'Route not found' }, status: :not_found
  end
end
