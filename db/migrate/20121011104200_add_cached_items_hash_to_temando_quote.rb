class AddCachedItemsHashToTemandoQuote < ActiveRecord::Migration
  def self.up
    add_column :spree_temando_quotes, :cached_items_hash, :string
  end

  def self.down
    remove_column :spree_temando_quotes, :cached_items_hash
  end
end
