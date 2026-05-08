# frozen_string_literal: true

class AddEnableSensitiveTagsToUsers < ActiveRecord::Migration[7.2]
  def change
    # enable_sensitive_tags is stored in bit_prefs, no column needed
  end
end