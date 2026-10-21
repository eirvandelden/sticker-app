require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest is served without authentication" do
    get manifest_path

    assert_response :success
    manifest = JSON.parse(response.body)

    assert_equal I18n.t("app.title"), manifest["name"]
    assert_equal "standalone", manifest["display"]
    assert manifest["icons"].any? { |icon| icon["sizes"] == "192x192" }
  end

  test "service worker is served without authentication" do
    get service_worker_path

    assert_response :success
  end

  test "application layout links the manifest" do
    sign_in_as(users(:parent))

    get parent_children_path

    assert_response :success
    assert_select "link[rel=manifest][href=?]", manifest_path
  end

  test "manifest and service worker load for a signed-out visitor" do
    assert_pwa_endpoints_load
  end

  test "manifest and service worker load for a signed-in parent and child" do
    [ users(:parent), users(:user) ].each do |user|
      sign_in_as(user)

      assert_pwa_endpoints_load
      delete session_path
    end
  end

  private

  def assert_pwa_endpoints_load
    get manifest_path

    assert_response :success
    assert_revalidating_cache_control

    get service_worker_path

    assert_response :success
    assert_revalidating_cache_control
    assert_includes response.body, "appkit-#{Appkit.revision}"
  end

  def assert_revalidating_cache_control
    %w[max-age=0 private must-revalidate].each do |directive|
      assert_includes response.headers["Cache-Control"], directive
    end
  end
end
