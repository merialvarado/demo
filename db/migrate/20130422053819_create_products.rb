class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.string :description
      t.string :author
      t.decimal :price
      t.date :available_on

      t.timestamps
    end
  end
end
