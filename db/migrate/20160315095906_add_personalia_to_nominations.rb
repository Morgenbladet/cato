class AddPersonaliaToNominations < ActiveRecord::Migration
  def change
    add_column :nominations, :gender, :string
    add_column :nominations, :year_of_birth, :integer
    add_column :nominations, :branch, :string
  end
end
