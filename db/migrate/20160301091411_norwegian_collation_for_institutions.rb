class NorwegianCollationForInstitutions < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE institutions ALTER COLUMN name TYPE varchar COLLATE "nb_NO";'
    execute 'ALTER TABLE institutions ALTER COLUMN abbreviation TYPE varchar COLLATE "nb_NO";'
  end
end
