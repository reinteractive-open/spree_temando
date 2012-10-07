module SpreeTemando
  class Engine < ::Rails::Engine
    isolate_namespace SpreeTemando

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/overrides/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer "spree_temando.register.shipping_calculators" do |app|
    end

    config.to_prepare &method(:activate).to_proc
  end
end
