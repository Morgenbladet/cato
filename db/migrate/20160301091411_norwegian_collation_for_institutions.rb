class NorwegianCollationForInstitutions < ActiveRecord::Migration
  def up
    if connection.adapter_name.downcase == "postgresql"
      execute 'ALTER TABLE institutions ALTER COLUMN name TYPE varchar COLLATE "nb_NO";'
      execute 'ALTER TABLE institutions ALTER COLUMN abbreviation TYPE varchar COLLATE "nb_NO";'
    end
  end
end
