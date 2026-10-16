# Gives the views link and navigation helpers.
# @rbs module-self: ActionView::Base
module ApplicationHelper
  # Returns the path of a QR code that signs the user in on another device.
  # QrCodeController expects an already-signed payload, not a raw URL.
  # @rbs (User user) -> String
  def transfer_qr_code_path(user)
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end

  # Renders a navigation link that is current on its exact page.
  # @rbs (String label, String path) -> String
  def nav_tab(label, path)
    link_to label, path, "aria-current": ("page" if current_page?(path))
  end

  # Renders a navigation link that is current anywhere in its section.
  # @rbs (String label, String path) -> String
  def nav_section_tab(label, path)
    link_to label, path, "aria-current": ("page" if within_section?(path))
  end

  private

  # Tells whether the request path is the path or below it.
  # @rbs (String path) -> bool
  def within_section?(path)
    request.path == path || request.path.start_with?("#{path}/")
  end
end
