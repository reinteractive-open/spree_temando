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
      quotes = find_quotes(destination, line_items)
      cheapest = quotes.sort_by { |q| q.total_price }.first
      { :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest }
    end

    def temando_origin
      o = Temando::Location.new(:suburb => preferred_origin_suburb, :postcode => preferred_origin_postcode, :country => 'AU')
      Rails.logger.debug o.inspect
      o
    end

    def compute(object)
      if object.is_a?(Spree::Shipment) && object.temando_quote.blank? then
        object.temando_quote = object.order.temando_quote
      end

      if object.temando_quote.blank? || object.temando_quote.outdated? then
        Spree::Order.transaction do
          destination = case object
                        when Spree::Order
                          object.shipping_address
                        when Spree::Shipment
                          object.address
                        else
                          raise "Unknown object: #{object.inspect}"
                        end

          data = estimate(destination.to_temando_location, object.line_items)

          quote = Spree::TemandoQuote.new_or_update_from_quote(object, data[:quote], destination)

          # Store the Quote data against the Order and these LineItems if they are persisted
          if object.persisted? then
            quote.save!

            object.temando_quote = quote
            object.update_column(:temando_quote_id, quote.id)

            object.line_items.each { |item| item.update_column(:temando_quote_id, quote.id) }
          end
        end
      end

      object.temando_quote.total_price
    end

private
    def find_quotes(destination, line_items)
      delivery = Temando::Delivery::DoorToDoor.new(self.temando_origin, destination)

      request = Temando::Request.new
      line_items.reject { |i| i.quantity < 1 }.each do |item|
        request.items << item.to_temando_item
      end

      request.quotes_for(delivery)
    end
  end
end
