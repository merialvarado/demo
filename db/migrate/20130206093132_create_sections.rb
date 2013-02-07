class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :header
      t.string :body
      t.string :section_type
      t.integer :document_id

      t.timestamps
    end
  end
end
