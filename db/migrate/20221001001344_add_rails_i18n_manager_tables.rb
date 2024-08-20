class AddRailsI18nManagerTables < ActiveRecord::Migration[6.0]
  def change

    create_table :rails_i18n_manager_translation_apps do |t|
      t.string :name
      t.string :default_locale
      t.text :additional_locales
      t.timestamps
    end

    create_table :rails_i18n_manager_translation_keys do |t|
      t.string :key
      t.references :translation_app, index: { name: 'index_translation_keys_on_translation_app_id' }
      t.boolean :active, default: true, null: false
      t.datetime :updated_at
    end

    create_table :rails_i18n_manager_translation_values do |t|
      t.references :translation_key, index: { name: 'index_translation_values_on_translation_key_id' }
      t.string :locale, limit: 5
      t.string :translation
      t.datetime :updated_at
    end

  end
end
