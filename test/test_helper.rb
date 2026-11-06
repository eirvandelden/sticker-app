ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthenticationTestHelper
  def sign_in_as(user, password: "password", follow_redirect: true)
    post session_path, params: { email_address: user.email, password: password }
    follow_redirect! if follow_redirect && response.redirect?
  end
end

module AllowanceSummaryAssertions
  # Asserts that the allowance term `label` is followed by a detail that matches `detail`.
  def assert_allowance_detail(label, detail)
    term = css_select("dl > dt").find { |node| node.text.strip == label }

    assert term, "no allowance term #{label.inspect} in the page"
    assert_match detail, term.next_element.text
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
  include AllowanceSummaryAssertions
end
