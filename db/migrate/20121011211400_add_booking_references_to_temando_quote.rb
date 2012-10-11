class AddBookingReferencesToTemandoQuote < ActiveRecord::Migration
  def self.up
    add_column :spree_temando_quotes, :booking_request, :string
    add_column :spree_temando_quotes, :booking_number, :string
    add_column :spree_temando_quotes, :consignment_number, :string
    add_column :spree_temando_quotes, :manifest_number, :string
  end

  def self.down
    remove_column :spree_temando_quotes, :booking_request
    remove_column :spree_temando_quotes, :booking_number
    remove_column :spree_temando_quotes, :consignment_number
    remove_column :spree_temando_quotes, :manifest_number
  end
end
