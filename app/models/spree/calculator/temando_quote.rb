module Spree
  class Calculator::TemandoQuote < Calculator
    # TODO: Add option to select insured
    # TODO: Add option to select express

    preference :origin_suburb, :string
    preference :origin_postcode, :string

    attr_accessible :preferred_origin_suburb, :preferred_origin_postcode

    def self.description
      I18n.t(:temando)
    end

    def self.available?(object)
      true
    end

    def estimate(destination, line_items)
      find_quotes(destination, line_items)
      cheapest = quotes.sort_by { |q| q.total_price }.first
      { :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest }
    end

    def temando_origin
      Temando::Location.new(:suburb => preferred_origin_suburb, :postcode => preferred_origin_postcode, :country => 'AU')
    end

    def compute(object)
      if object.temando_quote.blank? || object.temando_quote.outdated? then
        Spree::Order.transaction do
          data = estimate(object.shipping_address.to_temando_location, object.line_items)

          # Store the Quote data against the Order and these LineItems if they are persisted
          quote = Spree::TemandoQuote.new(data[:quote].merge(:address => object.shipping_address))

          if object.persisted? then
            quote.save!

            object.temando_quote = quote
            object.save!

            object.line_items.each { |item| item.update_attribute(:temando_quote_id, quote.id) }
          end
        end
      end

      object.temando_quote.total_price
    end

private
    def find_quotes(destination, line_items)
      delivery = Temando::Delivery::DoorToDoor.new(self.temando_origin, destination)

      request = Temando::Request.new
      line_items.each do |item|
        request.items << item.to_temando_item
      end

      quotes = request.quotes_for(delivery)
    end
  end
end
