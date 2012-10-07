module SpreeTemando
  module ProductShippingDecorator
    delegate :to_temando_item, :estimate_shipping, :to => :master
  end
end
Spree::Product.send(:include, SpreeTemando::ProductShippingDecorator)
