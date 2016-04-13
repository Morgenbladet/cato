class MultipleNominationsPerNominee < ActiveRecord::Migration

  def up
    create_table :reasons do |t|
      t.references :nomination, index: true, foreign_key: true
      t.string :nominator
      t.text :reason
      t.string :nominator_email
      t.boolean :verified, default: false

      t.timestamps null: false
    end

    Nomination.all.each do |n|
      Reason.create nomination_id: n.id,
        nominator: n.nominator,
        reason: n.reason,
        nominator_email: n.nominator_email,
        verified: n.verified,
        created_at: n.created_at,
        updated_at: n.updated_at
    end

    remove_column :nominations, :nominator, :string
    remove_column :nominations, :nominator_email, :string
    remove_column :nominations, :verified, :boolean, default: false
    remove_column :nominations, :reason, :text
  end

  def down
    say 'New nominations are created for nominees with multiple reasons.'
    say 'These new nominations will have different ids than before migration.'

    add_column :nominations, :nominator, :string
    add_column :nominations, :nominator_email, :string
    add_column :nominations, :verified, :boolean, default: false
    add_column :nominations, :reason, :text

    Reason.all do |r|
      n = r.nomination
      unless n.nominator_email.blank?
        n = Nomination.new(name: n.name, 
                           votes: 0, 
                           institution: n.institution,
                           gender: n.gender,
                           year_of_birth: n.year_of_birth,
                           branch: n.branch)
      end

      n.nominator_email = r.nominator_email
      n.nominator = r.nominator
      n.reason = r.reason
      n.verified = r.verified
      n.save!
    end

    drop_table :reasons
  end
end
