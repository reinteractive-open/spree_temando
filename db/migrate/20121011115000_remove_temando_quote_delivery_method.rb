class RemoveTemandoQuoteDeliveryMethod < ActiveRecord::Migration
  def self.up
    remove_column :spree_temando_quotes, :delivery_method
  end

  def self.down
    add_column :spree_temando_quotes, :delivery_method, :string
  end
end
