require 'digest/sha1'

module Spree
  # TemandoQuote object is a representation of the selected Quote provided by
  # the Temando API.
  class TemandoQuote < ActiveRecord::Base
    belongs_to :order
    belongs_to :shipment
    belongs_to :address
    belongs_to :calculator

    def outdated?
      self.current_items_hash != self.cached_items_hash
    end

    def calculator_hash
      Digest::SHA1.hexdigest(self.calculator.preferences.to_s)
    end

    def address_hash
      Digest::SHA1.hexdigest(self.address.attributes.to_s)
    end

    def current_items_hash
      data = (shipment || order).line_items.order(:variant_id).collect { |li| [ li.variant_id, li.quantity ].join(',') }.join(';')
      Digest::SHA1.hexdigest(calculator_hash + address_hash + data)
    end

    def self.new_or_update_from_quote(calculator, object, quote, address, data={})
      q = object.temando_quotes.find_by_calculator_id(calculator.id) || object.temando_quotes.new
      q.calculator = calculator

      if object.is_a?(Spree::Order) then
        q.order = object
      else
        q.shipment = object
      end

      [ :total_price, :tax, :currency, :minimum_eta, :maximum_eta, :name, :base_price, :guaranteed_eta, :carrier_id, :carrier_name, :carrier_phone, :delivery_method ].each do |field|
        q.send("#{field}=".to_sym, quote.send(field))
      end

      data.each do |field, value|
        q.send("#{field}=".to_sym, value)
      end

      q.address = address
      q.cached_items_hash = q.current_items_hash

      q
    end
  end
end
