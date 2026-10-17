# Groups the Action Cable base classes.
module ApplicationCable
  # Identifies a cable connection by the signed-in user.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # Identifies the connection by the verified user.
    # @rbs () -> void
    def connect
      # @type var connection: untyped
      connection = self
      connection.current_user = find_verified_user
    end

    private

    # Returns the user of the session cookie, or rejects the connection.
    # @rbs () -> User?
    def find_verified_user
      if session_token = cookies.signed[:session_token]
        session = Session.find_by(token: session_token)
        return session&.user if session
      end
      reject_unauthorized_connection
    end
  end
end
