class CreateNominations < ActiveRecord::Migration
  def change
    create_table :nominations do |t|
      t.references :institution, index: true, foreign_key: true
      t.string :name
      t.text :reason
      t.string :nominator
      t.string :nominator_email
      t.boolean :verified, default: false
      t.integer :votes, default: 0

      t.timestamps null: false
    end
  end
end
