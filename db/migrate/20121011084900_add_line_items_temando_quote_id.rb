class AddLineItemsTemandoQuoteId < ActiveRecord::Migration
  def self.up
    add_column :spree_line_items, :temando_quote_id, :integer
  end

  def self.down
    remove_column :spree_line_items, :temando_quote_id
  end
end
