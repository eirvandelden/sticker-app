# Is the abstract base class of every model.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
