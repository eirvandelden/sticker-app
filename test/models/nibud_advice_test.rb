require "test_helper"

class NibudAdviceTest < ActiveSupport::TestCase
  # Nibud zakgeld (weekly) age brackets (in cents):
  # 4-5: 50, 6-7: 75, 8-9: 100, 10-11: 150, 12-14: 250, 15-17: 450
  # Nibud kleedgeld (monthly) age brackets (in cents):
  # 12-14: 2000, 15-17: 4000

  def birthdate_for_age(years)
    Date.today - years.years
  end

  test "returns nil when birthdate is nil" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: nil, kind: :zakgeld, frequency: :weekly)
  end

  test "returns nil when child is younger than 4" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(3), kind: :zakgeld, frequency: :weekly)
  end

  test "returns nil when child is 18 or older" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(18), kind: :zakgeld, frequency: :weekly)
  end

  test "returns weekly zakgeld for age 4-5 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(5), kind: :zakgeld, frequency: :weekly)

    assert_equal 50, result
  end

  test "returns weekly zakgeld for age 6-7 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(7), kind: :zakgeld, frequency: :weekly)

    assert_equal 75, result
  end

  test "returns weekly zakgeld for age 8-9 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(9), kind: :zakgeld, frequency: :weekly)

    assert_equal 100, result
  end

  test "returns weekly zakgeld for age 10-11 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(10), kind: :zakgeld, frequency: :weekly)

    assert_equal 150, result
  end

  test "returns weekly zakgeld for age 12-14 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(13), kind: :zakgeld, frequency: :weekly)

    assert_equal 250, result
  end

  test "returns weekly zakgeld for age 15-17 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(16), kind: :zakgeld, frequency: :weekly)

    assert_equal 450, result
  end

  test "returns monthly kleedgeld for age 12-14 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(13), kind: :kleedgeld, frequency: :monthly)

    assert_equal 2000, result
  end

  test "returns monthly kleedgeld for age 15-17 bracket" do
    result = NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(16), kind: :kleedgeld, frequency: :monthly)

    assert_equal 4000, result
  end

  test "returns nil for kleedgeld when child is younger than 12" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(9), kind: :kleedgeld,
frequency: :monthly)
  end

  test "returns nil for zakgeld with monthly frequency — Nibud only publishes weekly zakgeld" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(10), kind: :zakgeld, frequency: :monthly)
  end

  test "returns nil for kleedgeld with weekly frequency — Nibud only publishes monthly kleedgeld" do
    assert_nil NibudAdvice.suggested_amount_cents(birthdate: birthdate_for_age(13), kind: :kleedgeld,
frequency: :weekly)
  end
end
