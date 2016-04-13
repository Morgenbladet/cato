class AddCounterCache < ActiveRecord::Migration
  def change
    add_column :nominations, :reasons_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        Nomination.ids.each do |id|
          Nomination.reset_counters(id, :reasons)
        end
      end
    end
  end
end
