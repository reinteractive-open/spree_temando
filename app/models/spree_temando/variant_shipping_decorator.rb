module SpreeTemando
  module VariantShippingDecorator
    def estimate_shipping(destination)
      line_item = Spree::LineItem.new
      line_item.variant = self
      line_item.quantity = 1
      Spree::Calculator::Temando.new.estimate_cheapest(destination, [line_item])
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
