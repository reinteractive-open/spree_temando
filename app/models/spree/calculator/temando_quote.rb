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

          quote = Spree::TemandoQuote.find_or_initialize_cheapest(object, temando_origin, destination, object.line_items)

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
  end
end
