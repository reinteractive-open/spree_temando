module SpreeTemando
  module VariantShippingDecorator
    def estimate_shipping(source, destination)
      delivery = Temando::Delivery::DoorToDoor.new(source, destination)

      request = Temando::Request.new
      request.items << self.to_temando_item

      quotes = request.quotes_for(delivery)
      cheapest = quotes.sort_by { |q| q.total_price }.first
      { :price => cheapest.total_price, :minimum_eta => cheapest.minimum_eta, :maximum_eta => cheapest.maximum_eta }
    end

    def to_temando_item
      item = Temando::Item::GeneralGoods.new
      item.height = self.height
      item.length = self.depth
      item.width  = self.width
      item.weight = self.weight
      item.quantity = 1
      item.description = self.name
      item
    end

  end
end
Spree::Variant.send(:include, SpreeTemando::VariantShippingDecorator)
