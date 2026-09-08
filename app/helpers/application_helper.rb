module ApplicationHelper
  # QrCodeController expects an already-signed payload, not a raw URL.
  def transfer_qr_code_path(user)
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end

  def nav_tab(label, path)
    link_to label, path, "aria-current": ("page" if current_page?(path))
  end

  def nav_section_tab(label, path)
    link_to label, path, "aria-current": ("page" if within_section?(path))
  end

  private

  def within_section?(path)
    request.path == path || request.path.start_with?("#{path}/")
  end
end
