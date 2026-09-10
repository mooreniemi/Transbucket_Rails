require 'spec_helper'
require 'yaml'

describe 'application locales' do
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar).freeze
  REQUIRED_KEYS = %w(site.description homepage.title homepage.intro header.home header.search footer.discord_prefix locale.label legal.translation_notice account_menu.login filter_menu.apply filter_menu.clear filter_menu.scope filter_menu.procedure filter_menu.surgeon directory.procedures_title directory.procedures_intro directory.surgeons_title directory.surgeons_intro directory.submissions directory.submissions_intro directory.recent_submissions directory.search_results directory.search_description directory.name directory.average_satisfaction directory.average_sensation directory.discussion_threads directory.register_to_see_more newsfeed.title newsfeed.description newsfeed.date newsfeed.entries.procedure_cleanup newsfeed.entries.prefix_search newsfeed.entries.discord_invite newsfeed.entries.locales views.pagination.first views.pagination.last views.pagination.previous views.pagination.next views.pagination.truncate).freeze
  REQUIRED_PUBLIC_ACTION_KEYS = %w(confirmations.are_you_sure actions.deleting actions.updating actions.update_caption).freeze
  REQUIRED_PUBLIC_EXTRA_KEYS = %w(add_procedure procedure_name describe_procedure contact_us return_email subject contact_message send edit_profile name username gender email password new_password password_confirmation current_password update profile_help new_submission editing_submission submissions_by_user post_op_sensation post_op_satisfaction image_caption caption browse_for_image browse sign_in sign_up navigation_toggle logo_alt top bottom face other ftm mtf error_count).freeze
  REQUIRED_EXPLANATION_KEYS = %w(username email password name gender tos).freeze
  REQUIRED_FLASH_KEYS = %w(content_flagged removed_flags destroy_failed destroyed contact_sent contact_invalid pin_created pin_updated).freeze
  REQUIRED_FILTER_SCOPES = %w(ftm mtf bottom top need_category).freeze
  REQUIRED_PROFILE_KEYS = %w(edit_title name email profile_help new_password current_password update submissions submit_now delete_confirm submission).freeze
  REQUIRED_SETTINGS_KEYS = %w(title safe_mode safe_mode_help notifications notifications_help update cancel_account cancel_warning cancel_confirm).freeze
  REQUIRED_CONFIRMATION_KEYS = %w(subject greeting instruction action).freeze
  REQUIRED_RESET_KEYS = %w(subject greeting instruction action instruction_2 instruction_3).freeze
  REQUIRED_PASSWORD_CHANGE_KEYS = %w(subject greeting message).freeze
  REQUIRED_UNLOCK_KEYS = %w(subject greeting message instruction action).freeze
  REQUIRED_COMMENT_MAILER_KEYS = %w(subject greeting posted reply this_link flag_help unsubscribe).freeze

  before do
    locale_files = Dir[File.expand_path('../config/locales/*.yml', __dir__)].sort
    expect(locale_files.map { |file| File.basename(file) }).to eq(['catalog.yml'])
    @translations = YAML.load_file(locale_files.first)
  end

  it 'defines the first-pass public UI keys for every supported locale' do
    SUPPORTED_LOCALES.each do |locale|
      REQUIRED_KEYS.each do |key|
        value = key.split('.').reduce(@translations.fetch(locale)) { |hash, part| hash.fetch(part) }
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_FILTER_SCOPES.each do |scope|
        value = @translations.fetch(locale).fetch('filter_scopes').fetch(scope)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_PUBLIC_ACTION_KEYS.each do |key|
        value = key.split('.').reduce(@translations.fetch(locale).fetch('public')) { |hash, part| hash.fetch(part) }
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_PUBLIC_EXTRA_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('public').fetch('extra').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_EXPLANATION_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('explanations').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_FLASH_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('flash').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      simple_form = @translations.fetch(locale).fetch('simple_form')
      expect(simple_form.fetch('required').fetch('text')).not_to be_empty
      expect(simple_form.fetch('required').fetch('mark')).not_to be_empty
      expect(simple_form.fetch('error_notification').fetch('default_message')).not_to be_empty
      REQUIRED_PROFILE_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('profile').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_SETTINGS_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('settings').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_CONFIRMATION_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('devise').fetch('mailer').fetch('confirmation_instructions').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      {
        'reset_password_instructions' => REQUIRED_RESET_KEYS,
        'password_change' => REQUIRED_PASSWORD_CHANGE_KEYS,
        'unlock_instructions' => REQUIRED_UNLOCK_KEYS
      }.each do |mailer, keys|
        keys.each do |key|
          value = @translations.fetch(locale).fetch('devise').fetch('mailer').fetch(mailer).fetch(key)
          expect(value).not_to be_nil
          expect(value).not_to eq('')
        end
      end
      REQUIRED_COMMENT_MAILER_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('comment_mailer').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
    end
  end
end
