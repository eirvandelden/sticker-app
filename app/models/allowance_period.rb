# Represents one due payment of an allowance, for pocket money or clothing money.
class AllowancePeriod < ApplicationRecord
  belongs_to :allowance
end
