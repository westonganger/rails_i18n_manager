require 'spec_helper'

RSpec.describe RailsI18nManager::GoogleTranslate, type: :model do

  before do
    allow(Rails.env).to receive(:test?).and_return(false)
    allow(RailsI18nManager.config).to receive(:google_translate_api_key).and_return("some-api-key")
  end

  context "translate" do
    it "returns false for unsupported locales" do
      expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "bar", to: "baz")).to eq(false)
    end

    it "returns false in test environment" do
      allow(Rails.env).to receive(:test?).and_return(true)
      expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "en", to: "es")).to eq(false)
    end

    it "returns false in development environment if api key is missing" do
      allow(RailsI18nManager.config).to receive(:google_translate_api_key).and_return(nil)
      allow(Rails.env).to receive(:development?).and_return(true)
      expect(RailsI18nManager::GoogleTranslate.translate("foo", from: "en", to: "es")).to eq(false)
    end

    it "returns false if HTML string provided" do
      expect(RailsI18nManager::GoogleTranslate.translate("<foo>", from: "en", to: "es")).to eq(false)

      allow(EasyTranslate).to receive(:translate).and_return("foo")
      expect(RailsI18nManager::GoogleTranslate.translate("<foo", from: "en", to: "es")).to eq("foo")
      expect(RailsI18nManager::GoogleTranslate.translate("foo>", from: "en", to: "es")).to eq("foo")
    end

    it "replaces single quote HTML entities with actual single quotes" do
      allow(EasyTranslate).to receive(:translate).and_return("&#39;foo&#39;")
      expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq("'foo'")
    end

    it "replaces '% {' with ' %{' for es locale" do
      allow(EasyTranslate).to receive(:translate).and_return("% {foo")
      expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq("%{foo")
    end

    it "returns nil if text was not able to be translated" do
      allow(EasyTranslate).to receive(:translate).and_return(nil)
      expect(RailsI18nManager::GoogleTranslate.translate("unrelated", from: "en", to: "es")).to eq(nil)
    end

    it "returns translated text" do
      allow(EasyTranslate).to receive(:translate).and_return("bonjour")
      expect(RailsI18nManager::GoogleTranslate.translate("hello", from: "en", to: "fr")).to eq("bonjour")
    end
  end

end
