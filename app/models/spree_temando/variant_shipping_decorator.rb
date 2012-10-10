module SpreeTemando
  module VariantShippingDecorator
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
