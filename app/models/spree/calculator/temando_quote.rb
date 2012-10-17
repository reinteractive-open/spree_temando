module Spree
  class Calculator::TemandoQuote < Calculator
    # TODO: Add option to select insured

    preference :origin_suburb, :string
    preference :origin_postcode, :string
    preference :express, :boolean

    attr_accessible :preferred_origin_suburb, :preferred_origin_postcode, :preferred_express

    def self.description
      I18n.t(:temando)
    end

    def available?(object)
      object.line_items.all? { |li| li.variant.temando_quotable? }
    end

    def cheapest(destination, line_items)
      quotes = find_quotes(destination, line_items)
      cheapest = quotes.sort_by { |q| q.total_price }.first
      { :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest }
    end

    def fastest(destination, line_items)
      quotes = find_quotes(destination, line_items)
      fastest_eta = quotes.collect(&:maximum_eta).min
      cheapest = quotes.reject { |q| q.maximum_eta > fastest_eta }.sort_by { |q| q.total_price }.first
      { :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest }
    end

    def temando_origin
      Temando::Location.new(:suburb => preferred_origin_suburb, :postcode => preferred_origin_postcode, :country => 'AU')
    end

    def compute(object)
      if object.is_a?(Spree::Shipment) && object.temando_quotes.blank? then
        object.temando_quotes = object.order.temando_quotes
      end

      existing_quote = object.temando_quotes.find_by_calculator_id(self.id)

      if existing_quote.blank? || existing_quote.outdated? then
        Spree::Order.transaction do
          destination = case object
                        when Spree::Order
                          object.shipping_address
                        when Spree::Shipment
                          object.address
                        else
                          raise "Unknown object: #{object.inspect}"
                        end

          if preferred_express then
            data = fastest(destination.to_temando_location, object.line_items)
          else
            data = cheapest(destination.to_temando_location, object.line_items)
          end

          quote = Spree::TemandoQuote.new_or_update_from_quote(self, object, data[:quote], destination)

          # Store the Quote data against the Order and these LineItems if they are persisted
          if object.persisted? then
            quote.save!

            object.line_items
          end

          existing_quote = quote
        end
      end

      existing_quote.total_price
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
