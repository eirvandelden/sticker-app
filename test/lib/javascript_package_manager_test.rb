require "test_helper"
require "open3"

class JavascriptPackageManagerTest < ActiveSupport::TestCase
  test "uses package-lock.json" do
    assert_predicate Rails.root.join("package-lock.json"), :file?
  end

  test "has no yarn lockfile" do
    assert_not_predicate Rails.root.join("yarn.lock"), :exist?
  end

  test "has no bin/yarn" do
    assert_not_predicate Rails.root.join("bin/yarn"), :exist?
  end

  test "bin/setup installs JavaScript packages with npm before preparing the database" do
    setup = Rails.root.join("bin/setup").read

    assert_includes setup, 'system!("npm install")'
    assert_operator setup.index("npm install"), :<, setup.index("db:prepare")
  end

  test "names yarn nowhere outside data" do
    output, = Open3.capture2("git", "grep", "-i", "-l", "yarn", "--", ".", ":!yarn.lock", ":!docs/changes",
      ":!test/lib/javascript_package_manager_test.rb", chdir: Rails.root.to_s)

    assert_empty output.split
  end
end
