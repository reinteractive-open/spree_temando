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

    def booked?
      self.booking_number.present?
    end

    def current_items_hash
      data = (shipment || order).line_items.order(:variant_id).collect { |li| [ li.variant_id, li.quantity ].join(',') }.join(';')
      Digest::SHA1.hexdigest(data)
    end

    def book!
      booking = self.to_temando_quote.book
      self.booking_request    = booking.request_id
      self.booking_number     = booking.number
      self.consignment_number = booking.consignment_number
      self.manifest_number    = booking.manifest_number
      self.save!
    end

    def to_temando_quote
      quote = Temando::Quote.new
      [ :total_price, :tax, :currency, :minimum_eta, :maximum_eta, :name, :base_price, :guaranteed_eta, :carrier_id ].each do |field|
        quote.send("#{field}=", self.send(field))
      end
      quote
    end

    def self.find_or_initialize_cheapest(object, origin, destination, line_items)
      quotes = find_quotes(origin, destination, line_items)
      cheapest = quotes.sort_by { |q| q.total_price }.first

      find_or_initialize_from_quote(object, cheapest, destination)
    end

    def self.find_or_initialize_from_quote(object, quote, address)
      q = object.temando_quote || Spree::TemandoQuote.new

      if object.is_a?(Spree::Order) then
        q.order = object
      else
        q.shipment = object
      end

      [ :total_price, :tax, :currency, :minimum_eta, :maximum_eta, :name, :base_price, :guaranteed_eta, :carrier_id ].each do |field|
        q.send("#{field}=".to_sym, quote.send(field))
      end

      q.address = address
      q.cached_items_hash = q.current_items_hash

      q
    end

    def self.find_quotes(origin, destination, line_items)
      destination = destination.to_temando_location if destination.respond_to?(:to_temando_location)

      delivery = Temando::Delivery::DoorToDoor.new(origin, destination)

      request = Temando::Request.new
      line_items.reject { |i| i.quantity < 1 }.each do |item|
        request.items << item.to_temando_item
      end

      request.quotes_for(delivery)
    end
  end
end
