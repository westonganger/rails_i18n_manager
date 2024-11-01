# CHANGELOG

### Unreleased - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.1...master)
- Allow `.yaml` files to be uploaded. Previously the upload validation would only allow `.yml`.
- Drop support for Rails v5.x
- [#19](https://github.com/westonganger/rails_i18n_manager/pull/19) - Fix width issue on translation values form and view page

### v1.0.1 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/v1.0.0...v1.0.1)
- [#14](https://github.com/westonganger/rails_i18n_manager/pull/14) - Remove usage of Array#intersection to fix errors in Ruby 2.6 and below
- [#12](https://github.com/westonganger/rails_i18n_manager/pull/12) - Fix for cleaning old tmp files created from TranslationKey#export_to
- [#11](https://github.com/westonganger/rails_i18n_manager/pull/11) - Fix google translate and add specs
- [#10](https://github.com/westonganger/rails_i18n_manager/pull/10) - Add missing pagination links to index pages

### v1.0.0 - [View Diff](https://github.com/westonganger/rails_i18n_manager/compare/9c8305c...v1.0.0)
- Release to rubygems

### April 17, 2023
- [#3](https://github.com/westonganger/rails_i18n_manager/pull/3) - Do not automatically load migrations and instead require an explicit migration install step

### April 2023
- Initial Release
