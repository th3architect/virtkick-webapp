class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action do
    next unless user_signed_in?

    if current_user.email.start_with? 'guest' and current_user.created_at <= 30.minutes.ago
      sign_out
      redirect_to '/'
    end
  end

  rescue_from Exception do |e|
    if request.format == 'application/json'
      if Rails.configuration.consider_all_requests_local
        render json: {exception: e.class.name, message: e.message}, status: 500
      else
        render json: {exception: true}, status: 500
      end
      Bugsnag.notify_or_ignore e
    else
      raise e
    end
  end

  before_bugsnag_notify :add_user_info_to_bugsnag

  private
  def add_user_info_to_bugsnag notif
    if user_signed_in?
      notif.user = {
          id: current_user.id,
          email: current_user.email
      }
    end
  end

  def render_progress progress_id
    render json: {progress_id: progress_id}
  end
end
