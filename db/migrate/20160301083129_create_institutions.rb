class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :abbreviation
      t.integer :priority

      t.timestamps null: false
    end
  end
end
