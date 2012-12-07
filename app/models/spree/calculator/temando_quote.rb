module Spree
  class Calculator::TemandoQuote < Calculator
    # TODO: Add option to select insured

    preference :origin_suburb, :string
    preference :origin_postcode, :string
    preference :express, :boolean
    preference :minimum_eta, :integer
    preference :pad_minimum, :integer
    preference :pad_maximum, :integer

    attr_accessible :preferred_origin_suburb, :preferred_origin_postcode, :preferred_express, :preferred_minimum_eta, :preferred_pad_minimum, :preferred_pad_maximum

    def self.description
      I18n.t(:temando)
    end

    def available?(object)
      object.line_items.all? { |li| li.variant.temando_quotable? }
    end

    def cheapest(destination, line_items)
      quotes = find_quotes(destination, line_items)
      return nil if quotes.nil?
      cheapest = quotes.sort_by { |q| q.total_price }.first
      if cheapest then
        pad_etas( :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest )
      else
        nil
      end
    end

    def fastest(destination, line_items)
      quotes = find_quotes(destination, line_items)
      return nil if quotes.nil?
      fastest_eta = quotes.collect(&:maximum_eta).min
      cheapest = quotes.reject { |q| q.maximum_eta > fastest_eta }.sort_by { |q| q.total_price }.first
      if cheapest then
        pad_etas( :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta, :quote => cheapest )
      else
        nil
      end
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

          return if data.nil?

          quote = Spree::TemandoQuote.new_or_update_from_quote(self, object, data[:quote], destination, data.slice(:minimum_eta, :maximum_eta))

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

      begin
        request = Temando::Request.new
        line_items.reject { |i| i.quantity < 1 }.each do |item|
          item = item.to_temando_item
          return nil if item.nil?
          request.items << item
        end

        request.quotes_for(delivery)
      rescue Temando::Api::Exceptions::SoapError
        return nil
      end
    end

    # Pads the ETAs in such a way that both dates are increased by eta_padding,
    # and the minimum_eta is never allowed lower than minimum_eta
    def pad_etas(data)
      data[:minimum_eta] = [ data[:minimum_eta] + (preferred_pad_minimum || 0), (preferred_minimum_eta || 0) ].max
      data[:maximum_eta] = [ data[:maximum_eta], (preferred_minimum_eta || 0) ].max + (preferred_pad_maximum || 0)
      data
    end
  end
end
