# Suggests a pocket money or clothing money amount from the age of a child, following the NIBUD guideline.
class NibudAdvice
  ZAKGELD_WEEKLY = [
    [ 4..5,   50 ],
    [ 6..7,   75 ],
    [ 8..9,   100 ],
    [ 10..11, 150 ],
    [ 12..14, 250 ],
    [ 15..17, 450 ]
  ].freeze

  KLEEDGELD_MONTHLY = [
    [ 12..14, 2000 ],
    [ 15..17, 4000 ]
  ].freeze

  # Returns the NIBUD amount in cents for the child's age, or nil when the guideline has none.
  # @rbs (birthdate: Date?, kind: String | Symbol, frequency: String | Symbol) -> Integer?
  def self.suggested_amount_cents(birthdate:, kind:, frequency:)
    return nil if birthdate.nil?

    age = age_in_years(birthdate)
    table = table_for(kind.to_sym, frequency.to_sym)
    return nil if table.nil?

    row = table.find { |range, _| range.include?(age) }
    row&.last
  end

  # Returns the NIBUD amounts for a kind and frequency, or nil when the guideline has none.
  # @rbs (Symbol kind, Symbol frequency) -> Array[[Range[Integer], Integer]]?
  def self.table_for(kind, frequency)
    return ZAKGELD_WEEKLY   if kind == :zakgeld   && frequency == :weekly
    return KLEEDGELD_MONTHLY if kind == :kleedgeld && frequency == :monthly

    nil
  end
  private_class_method :table_for

  # Returns the number of whole years since the birthdate.
  # @rbs (Date birthdate) -> Integer
  def self.age_in_years(birthdate)
    today = Date.today
    years = today.year - birthdate.year
    years -= 1 if today < birthdate + years.years
    years
  end
  private_class_method :age_in_years
end
