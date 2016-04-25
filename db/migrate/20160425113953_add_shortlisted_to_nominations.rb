class AddShortlistedToNominations < ActiveRecord::Migration
  def change
    change_table :nominations do |t|
      t.boolean :shortlisted, default: false
      t.text    :shortlist_reason
      t.text    :documentation
    end
  end
end
