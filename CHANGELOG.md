# CHANGELOG

### Unreleased - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.1.3...master)
- [#37](https://github.com/westonganger/rails_i18n_manager/pull/37) - Add recommended I18n configuration to the README
- [#36](https://github.com/westonganger/rails_i18n_manager/pull/36) - Many fixes on the Translations#index page
- [#35](https://github.com/westonganger/rails_i18n_manager/pull/35) - Fix render issues when there were form validation errors
- [#34](https://github.com/westonganger/rails_i18n_manager/pull/34) - Fix issue where CSS was missing utility classes for `float: right`
- [#33](https://github.com/westonganger/rails_i18n_manager/pull/33) - Add suggested workflow for teams

### v1.1.3 - February 9, 2025 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.1.2...v1.1.3)
- [#30](https://github.com/westonganger/rails_i18n_manager/pull/30) - Fix for Rails 6.x where the multipart form enctype was not being applied
- [#29](https://github.com/westonganger/rails_i18n_manager/pull/29) - Add `permitted_classes: [Symbol]` to `YAML.safe_load` call so that it will not error if there are values that start with a colon character (:)

### v1.1.2 - February 4, 2025 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.1.1...v1.1.2)
- [#28](https://github.com/westonganger/rails_i18n_manager/pull/28) - Dont use dig method in import which could result in exception `TypeError: Undefined method dig for String`
- [#27](https://github.com/westonganger/rails_i18n_manager/pull/27) - Only call File.read once for import

### v1.1.1 - February 4, 2025 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.1.0...v1.1.1)
- [#26](https://github.com/westonganger/rails_i18n_manager/pull/26) - Fix file not found issues with file import
- [#25](https://github.com/westonganger/rails_i18n_manager/pull/25) - Remove catch-all 404 route definition

### v1.1.0 - January 17, 2025 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.3...v1.1.0)
- [#24](https://github.com/westonganger/rails_i18n_manager/pull/24) - Completely remove usage of sprockets or propshaft
- [#23](https://github.com/westonganger/rails_i18n_manager/pull/23) - Fix issues with rubyzip 2.4+ create option

### v1.0.3 - December 2, 2024 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.2...v1.0.3)
- [#21](https://github.com/westonganger/rails_i18n_manager/pull/21) - Switch to digested assets using either propshaft or sprockets

### v1.0.2 - November 7, 2024 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.1...v1.0.2)
- [View commit](https://github.com/westonganger/rails_i18n_manager/commit/ccdeea7cdfb409b61e5d8ef23b03c52fbfd027c0) - Allow `.yaml` files to be uploaded. Previously the upload validation would only allow `.yml`.
- [View commit](https://github.com/westonganger/rails_i18n_manager/commit/65558c10ee8337d578b9f627034f3d6e29c2178f) - Drop support for Rails v5.x
- [#19](https://github.com/westonganger/rails_i18n_manager/pull/19) - Fix width issue on translation values form and view page

### v1.0.1 - October 17, 2023 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.0...v1.0.1)
- [#14](https://github.com/westonganger/rails_i18n_manager/pull/14) - Remove usage of Array#intersection to fix errors in Ruby 2.6 and below
- [#12](https://github.com/westonganger/rails_i18n_manager/pull/12) - Fix for cleaning old tmp files created from TranslationKey#export_to
- [#11](https://github.com/westonganger/rails_i18n_manager/pull/11) - Fix google translate and add specs
- [#10](https://github.com/westonganger/rails_i18n_manager/pull/10) - Add missing pagination links to index pages

### v1.0.0 - August 3, 2023 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/9c8305c...v1.0.0)
- Release to rubygems

### April 17, 2023
- [#3](https://github.com/westonganger/rails_i18n_manager/pull/3) - Do not automatically load migrations and instead require an explicit migration install step

### April 2023
- Initial Release
