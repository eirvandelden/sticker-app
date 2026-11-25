# Gives the views link and navigation helpers.
# @rbs module-self: ActionView::Base
# @rbs module-self: _RbsRailsPathHelpers
module ApplicationHelper
  # @type const Appkit::QrCodeLink: untyped
  # @type const Appkit::Menu::Link: untyped

  # Returns the path of a QR code that signs the user in on another device.
  # QrCodeController expects an already-signed payload, not a raw URL.
  # @rbs (User user) -> String
  def transfer_qr_code_path(user)
    # @type var user: untyped
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end

  # The title-bar back link of a record page: the menu's back link, else a link to the fallback
  # labelled with the current hub. Never nil, so a failed nested save still shows it.
  # @rbs (String fallback) -> untyped
  def record_back_link(fallback)
    menu.back(fallback) || Appkit::Menu::Link.new(label: menu.current_hub.label, path: fallback)
  end
end
