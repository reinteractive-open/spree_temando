module Spree
  # TemandoQuote object is a representation of the selected Quote provided by
  # the Temando API.
  class TemandoQuote < ActiveRecord::Base
    has_one :order
    belongs_to :address

    def outdated?
      true
    end
  end
end
