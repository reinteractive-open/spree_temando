module SpreeTemando
  module VariantShippingDecorator
    def temando_quotable?
      self.height.present? &&
      self.depth.present? &&
      self.width.present? &&
      self.weight.present?
    end

    def to_temando_item
      return nil unless self.temando_quotable?
      item = Temando::Item::GeneralGoods.new
      # NOTE: All the distances in Temando are in metres
      item.height = (self.height / 100.0)
      item.length = (self.depth / 100.0)
      item.width  = (self.width / 100.0)
      item.weight = self.weight
      item.quantity = 1
      item.description = self.name
      item
    end
  end
end
Spree::Variant.send(:include, SpreeTemando::VariantShippingDecorator)
