require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest is served without authentication" do
    get pwa_manifest_path(format: :json)

    assert_response :success
    manifest = JSON.parse(response.body)
    assert_equal I18n.t("app.title"), manifest["name"]
    assert_equal "standalone", manifest["display"]
    assert manifest["icons"].any? { |icon| icon["sizes"] == "192x192" }
  end

  test "application layout links the manifest" do
    get new_session_path

    assert_response :success
    assert_select "link[rel=manifest][href=?]", pwa_manifest_path(format: :json)
  end
end
