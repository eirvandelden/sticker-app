# frozen_string_literal: true

require "test_helper"

class I18nTest < ActiveSupport::TestCase
  def test_locales_are_present
    assert File.exist?(Rails.root.join("config/locales/en.yml"))
    assert File.exist?(Rails.root.join("config/locales/nl.yml"))
    assert File.exist?(Rails.root.join("config/locales/it.yml"))
  end

  def test_default_locale_is_english
    assert_equal :en, I18n.default_locale
  end

  def test_available_locales
    assert_includes I18n.available_locales, :en
    assert_includes I18n.available_locales, :nl
    assert_includes I18n.available_locales, :it
  end

  def test_i18n_tasks_health
    assert system("bundle", "exec", "i18n-tasks", "health")
  end
end
