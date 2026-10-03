# tinymce-rails 4.2 discovers locale packs through Rails.application.assets.
# That Sprockets environment intentionally does not exist when production is
# serving precompiled assets (config.assets.compile = false), yet the helper is
# still evaluated while rendering the pin form.  Use the checked-in locale
# packs in that case; development continues to use Sprockets' asset paths.
module TinyMCEProductionAssets
  def available_languages
    return super if assets

    Dir[Rails.root.join('vendor/assets/bower_components/tinymce/langs/*.js')].map do |path|
      File.basename(path, '.js')
    end
  end
end

TinyMCE::Rails::Configuration.singleton_class.prepend(TinyMCEProductionAssets)
