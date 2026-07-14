module Authentication
  extend ActiveSupport::Concern

  SESSION_COOKIE_LIFETIME = 1.year

  included do
    before_action :resume_session
    before_action :set_locale
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def resume_session
    if session_token = cookies.signed[:session_token]
      Current.session = Session.find_by(token: session_token)
      Current.user = Current.session&.user
      renew_session_cookie(session_token) if Current.user
    end
  end

  def start_new_session_for(user)
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    Current.session = session_record
    Current.user = user
    renew_session_cookie(session_record.token)
  end

  def renew_session_cookie(session_token)
    cookies.signed[:session_token] = {
      value: session_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: SESSION_COOKIE_LIFETIME.from_now
    }
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    Current.user = nil
    cookies.delete(:session_token)
  end

  def set_locale
    I18n.locale = Current.user&.locale || I18n.default_locale
  end

  def require_authentication
    resume_session if Current.user.nil?
    redirect_to new_session_path, alert: t("errors.authentication_required") unless Current.user
  end

  def post_authenticating_url
    after_login_path_for(Current.user)
  end

  def after_login_path_for(user)
    return child_dashboard_path if user.child?

    parent_children_path
  end
end
