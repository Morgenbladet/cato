class AddCounterCacheToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :nominations_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        Institution.ids.each do |id|
          Institution.reset_counters(id, :nominations)
        end
      end
    end
  end
end
