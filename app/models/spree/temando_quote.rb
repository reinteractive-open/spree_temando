require 'digest/sha1'

module Spree
  # TemandoQuote object is a representation of the selected Quote provided by
  # the Temando API.
  class TemandoQuote < ActiveRecord::Base
    has_one :order
    has_one :shipment
    belongs_to :address

    def outdated?
      self.current_items_hash != self.cached_items_hash
    end

    def current_items_hash
      data = (shipment || order).line_items.order(:variant_id).collect { |li| [ li.variant_id, li.quantity ].join(',') }.join(';')
      Digest::SHA1.hexdigest(data)
    end

    def self.new_or_update_from_quote(object, quote, address)
      q = object.temando_quote || Spree::TemandoQuote.new

      if object.is_a?(Spree::Order) then
        q.order = object
      else
        q.shipment = object
      end

      Rails.logger.debug quote.inspect
      [ :total_price, :tax, :currency, :minimum_eta, :maximum_eta, :name, :base_price, :guaranteed_eta, :carrier_id ].each do |field|
        q.send("#{field}=".to_sym, quote.send(field))
      end

      q.address = address
      q.cached_items_hash = q.current_items_hash

      q
    end
  end
end
