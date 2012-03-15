class AddDocument < ActiveRecord::Migration
  def up
    create_table :documents do |t|
      t.string    :external_identifier
      t.string    :internal_identifier
      t.string    :description

      t.references :document_record, :polymorphic => true
      t.references :document_type

      t.timestamps
    end

    add_index :documents, [:document_record_type, :document_record_id], :name => 'document_record_poly_idx'
    add_index :documents, :document_type_id, :name => 'document_type_idx'

    create_table :document_types do |t|
      t.string    :external_identifier
      t.string    :internal_identifier
      t.string    :description

      t.timestamps
    end
  end

  def down
    [:documents, :document_types].each do |table|
      drop_table table
    end
  end
end
