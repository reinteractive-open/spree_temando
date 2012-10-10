class AddTemandoQuoteAddressId < ActiveRecord::Migration
  def self.up
    add_column :spree_temando_quotes, :address_id, :integer
  end

  def self.down
    remove_column :spree_temando_quotes, :address_id
  end
end
