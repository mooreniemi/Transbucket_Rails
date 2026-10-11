module TouchPickerHelper
  # Data attributes that opt a <select> into touch_picker.js on phones and
  # tablets, with its text already translated.
  def touch_picker_data(title, placeholder = title)
    {
      'data-touch-picker' => 'true',
      'data-picker-title' => title,
      'data-picker-placeholder' => placeholder,
      'data-picker-search' => t('header.search'),
      'data-picker-done' => t('public.picker.done'),
      'data-picker-close' => t('public.picker.close'),
      'data-picker-empty' => t('public.picker.no_matches'),
      'data-picker-remove' => t('public.form.remove')
    }
  end
end
