class NorwegianCollationForNominations < ActiveRecord::Migration
  def up
    if connection.adapter_name.downcase == "postgresql"
      execute 'ALTER TABLE nominations ALTER COLUMN name TYPE varchar COLLATE "nb_NO";'
    end
  end
end
