class AddPageFieldsToEventTypes < ActiveRecord::Migration[7.1]
  def up
    # Event types were card-only until each one got a page of its own at
    # /events/<slug>, which needs an address and room for real body copy.
    add_column :event_types, :slug, :jsonb, default: {}
    add_column :event_types, :description, :jsonb, default: {}

    # Existing rows all start on the same empty default, so the unique index
    # cannot go on until each has an address. Derive one from the name here;
    # the seed narrows "corporate-events" to "corporate" afterwards.
    execute <<~SQL
      UPDATE event_types
      SET slug = jsonb_build_object(
        'en', trim(both '-' from regexp_replace(lower(name->>'en'), '[^a-z0-9]+', '-', 'g')),
        'id', trim(both '-' from regexp_replace(lower(coalesce(name->>'id', name->>'en')), '[^a-z0-9]+', '-', 'g'))
      )
      WHERE name->>'en' IS NOT NULL
    SQL

    add_index :event_types, :slug, unique: true
  end

  def down
    remove_index  :event_types, :slug
    remove_column :event_types, :description
    remove_column :event_types, :slug
  end
end
