class AddCarrierDataToTemandoQuote < ActiveRecord::Migration
  def change
    add_column :spree_temando_quotes, :carrier_name, :string
    add_column :spree_temando_quotes, :carrier_phone, :string
    add_column :spree_temando_quotes, :delivery_method, :string
  end
end
