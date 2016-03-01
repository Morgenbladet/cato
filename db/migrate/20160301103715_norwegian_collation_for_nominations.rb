class NorwegianCollationForNominations < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE nominations ALTER COLUMN name TYPE varchar COLLATE "nb_NO";'
  end
end
