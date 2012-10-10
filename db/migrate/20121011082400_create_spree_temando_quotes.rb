class CreateSpreeTemandoQuotes < ActiveRecord::Migration
  def self.up
    create_table :spree_temando_quotes do |t|
      t.decimal :total_price,    :scale => 2, :precision => 6
      t.decimal :base_price,     :scale => 2, :precision => 6
      t.decimal :tax,            :scale => 2, :precision => 6
      t.string  :currency
      t.integer :minimum_eta
      t.integer :maximum_eta

      t.string  :name

      t.string  :delivery_method
      t.boolean :guaranteed_eta
      t.string  :carrier_id

      t.timestamps
    end

  end

  def self.down
    drop_table :spree_temando_quotes
  end
end

