class CreateValidDocuments < ActiveRecord::Migration
  def up
    unless table_exists?(:valid_documents)
      create_table :valid_documents do |t|
        t.references :document
        t.references :documented_model, :polymorphic => true
      end

      add_index :valid_documents, :document_id
      add_index :valid_documents, [:documented_model_id, :documented_model_type], :name => 'valid_documents_model_idx'
    end
  end

  def down
  end
end
