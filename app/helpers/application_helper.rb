# @rbs module-self: ActionView::Base
module ApplicationHelper
  # QrCodeController expects an already-signed payload, not a raw URL.
  # @rbs (User user) -> String
  def transfer_qr_code_path(user)
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end

  # @rbs (String label, String path) -> String
  def nav_tab(label, path)
    link_to label, path, "aria-current": ("page" if current_page?(path))
  end

  # @rbs (String label, String path) -> String
  def nav_section_tab(label, path)
    link_to label, path, "aria-current": ("page" if within_section?(path))
  end

  private

  # @rbs (String path) -> bool
  def within_section?(path)
    request.path == path || request.path.start_with?("#{path}/")
  end
end
