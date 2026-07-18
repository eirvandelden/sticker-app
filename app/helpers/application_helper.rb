module ApplicationHelper
  # QrCodeController expects an already-signed payload, not a raw URL.
  def transfer_qr_code_path(user)
    qr_code_path(Appkit::QrCodeLink.new(session_transfer_url(user.transfer_id)).signed)
  end
end
