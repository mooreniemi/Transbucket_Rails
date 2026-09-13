(function($) {
  function sortValue(row, key) {
    var value = row.getAttribute('data-sort-' + key);
    if (key === 'name') {
      return (value || '').toLowerCase();
    }
    return value === null || value === '' ? null : parseFloat(value);
  }

  $(function() {
    $('.sortable-directory-table').each(function() {
      var table = this;
      $(table).find('.directory-sort-button').on('click', function() {
        var button = this;
        var key = button.getAttribute('data-sort-key');
        var descending = button.getAttribute('aria-sort') === 'ascending';
        var rows = $(table).find('tbody > tr').get();

        rows.sort(function(left, right) {
          var a = sortValue(left, key);
          var b = sortValue(right, key);
          if (a === b) return 0;
          if (a === null) return 1;
          if (b === null) return -1;
          var result = a < b ? -1 : 1;
          return descending ? -result : result;
        });

        $(table).find('.directory-sort-button').attr('aria-sort', 'none');
        button.setAttribute('aria-sort', descending ? 'descending' : 'ascending');
        $(table).find('tbody').append(rows);
      });
    });
  });
}(jQuery));
