class FixTemandoQuoteAssociations < ActiveRecord::Migration
  def self.up
    Spree::TemandoQuote.delete_all

    add_column :spree_temando_quotes, :calculator_id, :integer, :null => false
    add_column :spree_temando_quotes, :order_id, :integer
    add_column :spree_temando_quotes, :shipment_id, :integer

    remove_column :spree_orders, :temando_quote_id
    remove_column :spree_shipments, :temando_quote_id
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
