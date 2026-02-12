# frozen_string_literal: true

require 'test_helper'

class I18nTest < ActiveSupport::TestCase
  # i18n-tasks gem removed due to Ruby 4.0 compatibility issues
  # Tests skipped - consider re-enabling when gem is updated or use manual verification

  def test_locales_are_present
    assert File.exist?(Rails.root.join('config/locales/en.yml'))
    assert File.exist?(Rails.root.join('config/locales/nl.yml'))
  end

  def test_default_locale_is_english
    assert_equal :en, I18n.default_locale
  end

  def test_available_locales
    assert_includes I18n.available_locales, :en
    assert_includes I18n.available_locales, :nl
  end
end
