# frozen_string_literal: true

class RemoveEmailAddressesTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :email_addresses
  end

  def down
    create_table :email_addresses do |t|
      t.string :address, null: false
      t.timestamps
      t.boolean :is_deliverable, default: true
      t.boolean :is_verified, default: false
      t.references :user, null: false, foreign_key: true
    end

    add_index :email_addresses, :address
    add_index :email_addresses, :address, using: :gin, opclass: :gin_trgm_ops
    add_index :email_addresses, :is_deliverable, where: "(is_deliverable = false)"
    add_index :email_addresses, :is_verified, where: "(is_verified = false)"
    add_index :email_addresses, :user_id, unique: true
  end
end
