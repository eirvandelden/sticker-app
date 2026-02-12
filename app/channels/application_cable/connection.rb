module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if session_token = cookies.signed[:session_token]
        session = Session.find_by(token: session_token)
        return session&.user if session
      end
      reject_unauthorized_connection
    end
  end
end
