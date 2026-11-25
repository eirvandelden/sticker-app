# Gives the views link and navigation helpers.
# @rbs module-self: ActionView::Base
# @rbs module-self: _RbsRailsPathHelpers
module ApplicationHelper
  # @type const Appkit::QrCodeLink: untyped

  # Returns the path of a QR code that signs the user in on another device.
  # QrCodeController expects an already-signed payload, not a raw URL.
  # @rbs (User user) -> String
  def transfer_qr_code_path(user)
    # @type var user: untyped
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end
end
