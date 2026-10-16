# Represents one due pocket-money payment of an allowance.
class AllowancePeriod < ApplicationRecord
  belongs_to :allowance
end
