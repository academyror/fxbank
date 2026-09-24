# frozen_string_literal: true

class AddMetadataAndFxQuoteToTransfers < ActiveRecord::Migration[7.2]
  def change
    add_reference :transfers, :fx_quote, type: :uuid, foreign_key: true, null: true
    add_column :transfers, :metadata, :jsonb, default: {}, null: false
    add_index :transfers, :metadata, using: :gin
  end
end
