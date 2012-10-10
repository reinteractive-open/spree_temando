module SpreeTemando
  module AddressDecorator
    def to_temando_location
      location = Temando::Location.new
      location.postcode = self.zipcode
      location.suburb   = self.city
      location.contact  = "#{self.firstname} #{self.lastname}"
      location.state    = self.state.name
      location.street   = [ self.address1, self.address2 ].compact.join(' , ')
      location.phone1   = self.phone
      location.phone2   = self.alternative_phone
      location.company  = self.company

      raise 'Temando only ships to Australia' unless self.country.try(:name) == 'Australia'
      location.country = 'AU'

      location
    end

  end
end
Spree::Address.send(:include, SpreeTemando::AddressDecorator)
