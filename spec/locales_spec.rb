require 'spec_helper'
require 'yaml'

describe 'application locales' do
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar sv).freeze
  REQUIRED_KEYS = %w(site.description homepage.title homepage.intro header.home header.search header.safe_mode_on header.safe_mode_off footer.discord_prefix locale.label legal.translation_notice account_menu.login filter_menu.apply filter_menu.clear filter_menu.scope filter_menu.procedure filter_menu.surgeon directory.procedures_title directory.procedures_intro directory.surgeons_title directory.surgeons_intro directory.submissions directory.submissions_intro directory.recent_submissions directory.recent directory.for_you directory.search_results directory.search_description directory.name directory.average_satisfaction directory.average_sensation directory.discussion_threads directory.register_to_see_more newsfeed.title newsfeed.description newsfeed.date newsfeed.entries.procedure_cleanup newsfeed.entries.prefix_search newsfeed.entries.discord_invite newsfeed.entries.locales views.pagination.first views.pagination.last views.pagination.previous views.pagination.next views.pagination.truncate).freeze
  REQUIRED_PROCEDURE_GUIDE_KEYS = %w(procedure_guide.sources_title procedure_guide.title_suffix procedure_guide.community_title procedure_guide.community_note procedure_guide.related_title).freeze
  REQUIRED_PUBLIC_ACTION_KEYS = %w(confirmations.are_you_sure actions.deleting actions.updating actions.update_caption).freeze
  REQUIRED_PUBLIC_PIN_KEYS = %w(doctor_prefix updated tap_to_reveal hide_image comments_label report edit_post delete_post report_confirm report_comment_confirm reported).freeze
  REQUIRED_PUBLIC_AUTH_KEYS = %w(username username_or_email password show_password hide_password have_account new_here password_hint pronouns pronouns_default pronouns_other pronouns_placeholder pronouns_invalid).freeze
  REQUIRED_PUBLIC_EXTRA_KEYS = %w(add_procedure procedure_name describe_procedure contact_us return_email subject contact_message send edit_profile name username gender email password new_password password_confirmation current_password update profile_help new_submission editing_submission submissions_by_user post_op_sensation post_op_satisfaction image_caption caption browse_for_image browse sign_in sign_up navigation_toggle logo_alt top bottom face other ftm mtf error_count).freeze
  REQUIRED_EXPLANATION_KEYS = %w(username email password name gender pronouns tos).freeze
  REQUIRED_FLASH_KEYS = %w(content_flagged removed_flags destroy_failed destroyed contact_sent contact_invalid pin_created pin_updated).freeze
  REQUIRED_FILTER_SCOPES = %w(ftm mtf bottom top need_category).freeze
  REQUIRED_PROFILE_KEYS = %w(edit_title name email profile_help password_required_hint new_password current_password update submissions submit_now delete_confirm submission).freeze
  REQUIRED_SETTINGS_KEYS = %w(title safe_mode safe_mode_help notifications notifications_help update cancel_account cancel_warning cancel_confirm).freeze
  REQUIRED_CONFIRMATION_KEYS = %w(subject greeting instruction action reminder_notice reminder_help).freeze
  REQUIRED_RESET_KEYS = %w(subject greeting instruction action instruction_2 instruction_3).freeze
  REQUIRED_PASSWORD_CHANGE_KEYS = %w(subject greeting message).freeze
  REQUIRED_UNLOCK_KEYS = %w(subject greeting message instruction action).freeze
  REQUIRED_COMMENT_MAILER_KEYS = %w(subject greeting posted reply this_link flag_help unsubscribe).freeze
  REQUIRED_COMPLICATION_FORM_KEYS = %w(cost_question insurance_question insurance_yes insurance_no revision_question sensation_question satisfaction_question complication_tags complications_question complications_yes complications_no complications_help complications_validation).freeze

  before do
    I18n.available_locales = SUPPORTED_LOCALES.map(&:to_sym)
    locale_files = Dir[File.expand_path('../config/locales/*.yml', __dir__)].sort
    expect(locale_files.map { |file| File.basename(file) }).to eq(['about.yml', 'catalog.yml', 'comparison.yml', 'form_guidance.yml', 'procedure_guide.yml', 'rating.yml', 'zz_procedure_names.yml'])
    @translations = YAML.load_file(locale_files.find { |file| file.end_with?('catalog.yml') })
    # Swedish is a partial block in the catalog; whatever it lacks falls back to English at runtime.
    @translations['sv'] = deep_merge(@translations.fetch('en'), @translations.fetch('sv'))
    procedure_guide = YAML.load_file(locale_files.find { |file| file.end_with?('procedure_guide.yml') })
    procedure_guide.each do |locale, values|
      @translations[locale] = deep_merge(@translations.fetch(locale), values)
    end
    form_guidance = YAML.load_file(locale_files.find { |file| file.end_with?('form_guidance.yml') })
    form_guidance.each do |locale, values|
      @translations[locale] = deep_merge(@translations.fetch(locale), values)
    end
    @about_translations = YAML.load_file(locale_files.find { |file| file.end_with?('about.yml') })
    @procedure_names = YAML.load_file(locale_files.find { |file| file.end_with?('zz_procedure_names.yml') })
  end

  def deep_merge(base, overrides)
    base.merge(overrides) do |_key, original, override|
      original.is_a?(Hash) && override.is_a?(Hash) ? deep_merge(original, override) : override
    end
  end

  it 'defines every About page translation for every supported locale' do
    keys = %w(title meta_description origin welcome_heading welcome community_note funding_heading funding help_heading help github_link contact contact_form)
    SUPPORTED_LOCALES.each do |locale|
      keys.each do |key|
        value = @about_translations.fetch(locale).fetch('about').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
    end
  end

  it 'defines the first-pass public UI keys for every supported locale' do
    SUPPORTED_LOCALES.each do |locale|
      REQUIRED_KEYS.each do |key|
        value = key.split('.').reduce(@translations.fetch(locale)) { |hash, part| hash.fetch(part) }
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_PROCEDURE_GUIDE_KEYS.each do |key|
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
      REQUIRED_PUBLIC_PIN_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('public').fetch('pin').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_PUBLIC_AUTH_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('public').fetch('auth').fetch(key)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_COMPLICATION_FORM_KEYS.each do |key|
        value = @translations.fetch(locale).fetch('public').fetch('form').fetch(key)
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

  it 'defines reviewed high-volume procedure labels for every supported locale' do
    required_names = [
      'double incision with grafts',
      'periareolar mastectomy (keyhole)',
      'bilateral mastectomy',
      'metoidioplasty',
      "metoidioplasty ('meta')",
      'rff phalloplasty'
    ]

    SUPPORTED_LOCALES.each do |locale|
      aliases = @procedure_names.fetch(locale).fetch('procedure_aliases')
      required_names.each do |name|
        expect(aliases.fetch(name)).not_to be_empty
      end
    end
  end

  it 'defines Swedish overrides for the public mailers' do
    swedish = @translations.fetch('sv')
    %w[confirmation_instructions reset_password_instructions unlock_instructions password_change].each do |mailer|
      subject = swedish.fetch('devise').fetch('mailer').fetch(mailer).fetch('subject')
      expect(subject).not_to match(/[A-Za-z]{4,} instructions|Your password/)
    end
    expect(swedish.fetch('comment_mailer').fetch('greeting')).to include('Hej')
  end

  it 'defines every comparison string for every supported locale with the same placeholders' do
    comparison = YAML.load_file(File.expand_path('../config/locales/comparison.yml', __dir__))
    english = comparison.fetch('en').fetch('comparison')
    placeholders = ->(text) { text.to_s.scan(/%\{[^}]+\}/).sort }

    SUPPORTED_LOCALES.each do |locale|
      translated = comparison.fetch(locale).fetch('comparison')
      english.each do |key, text|
        expect(translated.fetch(key).to_s).not_to be_empty, "#{locale} is missing comparison.#{key}"
        expect(placeholders.call(translated.fetch(key))).to eq(placeholders.call(text)),
          "#{locale} comparison.#{key} placeholders differ from English"
      end
    end
  end

  it 'defines the touch picker strings for every supported locale' do
    SUPPORTED_LOCALES.each do |locale|
      %w(done close no_matches).each do |key|
        value = @translations.fetch(locale).fetch('public').fetch('picker').fetch(key)
        expect(value.to_s).not_to be_empty, "#{locale} is missing public.picker.#{key}"
      end
    end
  end

  it 'keeps a trailing space on the doctor prefix so names are not glued to it' do
    SUPPORTED_LOCALES.each do |locale|
      prefix = @translations.fetch(locale).fetch('public').fetch('pin').fetch('doctor_prefix')
      expect(prefix).to match(/\s\z/), "#{locale} doctor_prefix #{prefix.inspect} has no trailing space"
    end
  end

  # YAML 1.1 reads an unquoted Yes/No/On/Off as a boolean, which then renders as
  # "true"/"false" in the page. That is what happened to the pin form's Yes/No
  # answers in English, Spanish and Italian. Only the number formats may be booleans.
  it 'has no translation that YAML turned into a boolean' do
    booleans = []
    walk = lambda do |node, path|
      case node
      when Hash then node.each { |key, value| walk.call(value, path + [key.to_s]) }
      when TrueClass, FalseClass then booleans << path.join('.')
      end
    end

    Dir[File.expand_path('../config/locales/*.yml', __dir__)].sort.each do |file|
      walk.call(YAML.load_file(file), [File.basename(file)])
    end

    expect(booleans.reject { |path| path.include?('.number.') }).to eq([])
  end
end
