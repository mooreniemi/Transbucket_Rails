# Tags confirmation reminder emails with a SendGrid category via the legacy
# X-SMTPAPI header, so they're filterable in SendGrid's dashboard separately
# from ordinary confirmation, password-reset, etc. mail sent through the same
# account. Headers set here before `super` calls `mail(...)` survive onto the
# final outgoing message (see Devise::Mailer#confirmation_instructions).
class TransbucketDeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    with_locale(record, opts) do
      if record.confirmation_reminder
        headers['X-SMTPAPI'] = { category: ['confirmation_reminder'] }.to_json
      end
      super(record, token, mailer_options(opts))
    end
  end

  def reset_password_instructions(record, token, opts = {})
    with_locale(record, opts) { super(record, token, mailer_options(opts)) }
  end

  def unlock_instructions(record, token, opts = {})
    with_locale(record, opts) { super(record, token, mailer_options(opts)) }
  end

  def password_change(record, opts = {})
    with_locale(record, opts) { super(record, mailer_options(opts)) }
  end

  def email_changed(record, opts = {})
    with_locale(record, opts) { super(record, mailer_options(opts)) }
  end

  private

  def with_locale(record, opts)
    locale = opts[:locale].presence || I18n.locale
    I18n.with_locale(locale) { yield }
  end

  def mailer_options(opts)
    opts.except(:locale)
  end
end
