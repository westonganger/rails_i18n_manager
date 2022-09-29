require 'spec_helper'

RSpec.describe RailsI18nManager::Config, type: :model do

  context "google_translate_api_key" do
    before do
      @prev_google_translate_api_key = RailsI18nManager.config.google_translate_api_key
    end

    after do
      RailsI18nManager.config.google_translate_api_key = @prev_google_translate_api_key
    end

    it "allows assignment" do
      RailsI18nManager.config.google_translate_api_key = "foo"
      expect(RailsI18nManager.config.google_translate_api_key).to eq("foo")
    end
  end

end
