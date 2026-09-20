// Shows the free-text pronouns box only while "Other" is selected.
// Plain ES5: the asset pipeline minifies with Uglifier.
$(document).on('change', '.pronouns-select', function () {
  var custom = $(this).closest('form').find('.pronouns-custom');
  var wantsCustom = this.value === 'custom';
  custom.prop('hidden', !wantsCustom);
  if (wantsCustom) { custom.focus(); }
});
