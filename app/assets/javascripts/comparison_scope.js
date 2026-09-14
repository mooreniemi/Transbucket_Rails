$(document).ready(function() {
  $('.rating-comparison-form form').each(function() {
    var form = $(this);
    var first = form.find('#first_id');
    var second = form.find('#second_id');
    var scope = form.find('[data-comparison-scope-select]');
    if (!scope.length) return;

    var memberships = JSON.parse(form.attr('data-comparison-scope-memberships') || '{}');

    function allowedScopeIds() {
      var firstIds = memberships[first.val()] || [];
      var secondIds = memberships[second.val()] || [];
      if (!first.val() && !second.val()) return null;
      if (!first.val()) return secondIds;
      if (!second.val()) return firstIds;
      return $.grep(firstIds, function(id) { return $.inArray(id, secondIds) !== -1; });
    }

    function updateScopeOptions() {
      var allowed = allowedScopeIds();
      scope.find('option').each(function() {
        var option = $(this);
        var isBlank = option.val() === '';
        var isAllowed = isBlank || allowed === null || $.inArray(option.val(), allowed) !== -1;
        option.prop('disabled', !isAllowed).toggle(isAllowed);
      });
      if (scope.find('option:selected').prop('disabled')) scope.val('');
    }

    first.add(second).on('change', updateScopeOptions);
    updateScopeOptions();
  });
});
