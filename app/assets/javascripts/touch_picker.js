// Touch-friendly replacement for <select> on phones and tablets.
//
// Chosen (the desktop widget) switches itself off on phones, which used to leave
// raw <select multiple> boxes in the feed filter and a bare native dropdown with
// hundreds of surgeons on the new-pin form. On touch devices any
// <select data-touch-picker> is enhanced instead:
//   * a short multi-select (8 options or fewer) becomes inline toggle chips;
//   * everything else becomes a button that opens a full-screen sheet with a
//     search field (for long lists) and 48px tap targets.
// The native <select> stays in the form, hidden, as the source of truth, so
// submission and existing scripts keep working; it gets a real "change" event
// whenever the picker changes it, and the picker re-reads it on "chosen:updated".
//
// Text comes from data attributes on the select (data-picker-title, -placeholder,
// -search, -done, -close, -empty, -remove) so it stays translated by Rails.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  var TOUCH_QUERY = '(max-width: 767px), (pointer: coarse)';
  var INLINE_LIMIT = 8;
  var SEARCH_THRESHOLD = 10;
  var openPicker = null;

  function shouldUse() {
    return !!(window.matchMedia && window.matchMedia(TOUCH_QUERY).matches);
  }

  function prefersTouchKeyboard() {
    return !!(window.matchMedia && window.matchMedia('(pointer: coarse)').matches);
  }

  // Case- and accent-insensitive comparison text.
  function fold(text) {
    var value = (text || '').toString().toLowerCase();
    if (value.normalize) { value = value.normalize('NFD').replace(/[̀-ͯ]/g, ''); }
    return value;
  }

  function create(tag, className, text) {
    var node = document.createElement(tag);
    if (className) { node.className = className; }
    if (text !== undefined && text !== null) { node.textContent = text; }
    return node;
  }

  function icon(name) {
    var node = create('i', 'fa fa-' + name);
    node.setAttribute('aria-hidden', 'true');
    return node;
  }

  function button(className, text) {
    var node = create('button', className, text);
    node.type = 'button';
    return node;
  }

  function attr(select, name, fallback) {
    return select.getAttribute('data-picker-' + name) || fallback || '';
  }

  function readOptions(select) {
    var items = [];
    Array.prototype.forEach.call(select.options, function(option) {
      if (option.value === '') { return; }
      items.push({ value: option.value, label: option.text, option: option });
    });
    return items;
  }

  function fireChange(select) {
    var event;
    if (typeof window.Event === 'function') {
      event = new window.Event('change', { bubbles: true });
    } else {
      event = document.createEvent('Event');
      event.initEvent('change', true, false);
    }
    select.dispatchEvent(event);
  }

  function lockScroll(locked) {
    var classes = document.body.className.replace(/(^|\s)picker-open(?=\s|$)/g, '').replace(/^\s+|\s+$/g, '');
    document.body.className = locked ? (classes + ' picker-open').replace(/^\s+/, '') : classes;
  }

  function enhance(select) {
    if (!select || select.getAttribute('data-picker-ready')) { return; }
    select.setAttribute('data-picker-ready', 'true');

    var multiple = select.multiple;
    var title = attr(select, 'title');
    var placeholder = attr(select, 'placeholder', title);
    var items = readOptions(select);
    var inline = multiple && items.length <= INLINE_LIMIT;
    var root = create('div', 'picker' + (inline ? ' picker-inline' : ''));
    var trigger, triggerText, triggerCount, selectedList;

    select.className += ' picker-native';
    select.setAttribute('tabindex', '-1');
    select.setAttribute('aria-hidden', 'true');
    select.parentNode.insertBefore(root, select.nextSibling);

    // ---- inline chips: short multi-selects such as the gender/area filter
    if (inline) {
      root.setAttribute('role', 'group');
      root.setAttribute('aria-label', title);
      items.forEach(function(item) {
        var chip = button('picker-chip', item.label);
        chip.setAttribute('role', 'checkbox');
        chip.addEventListener('click', function() {
          item.option.selected = !item.option.selected;
          fireChange(select);
          refresh();
        });
        item.chip = chip;
        root.appendChild(chip);
      });
    } else {
      // ---- sheet: a trigger button, plus removable chips for multiple selects
      trigger = button('picker-trigger');
      trigger.setAttribute('aria-haspopup', 'dialog');
      trigger.setAttribute('aria-expanded', 'false');
      if (select.id) {
        trigger.id = select.id + '_picker';
        var label = document.querySelector('label[for="' + select.id + '"]');
        if (label) { label.setAttribute('for', trigger.id); }
      }
      if (title && !select.id) { trigger.setAttribute('aria-label', title); }
      triggerText = create('span', 'picker-trigger-text');
      triggerCount = create('span', 'picker-count');
      trigger.appendChild(triggerText);
      trigger.appendChild(triggerCount);
      trigger.appendChild(icon('chevron-down'));
      root.appendChild(trigger);
      if (multiple) {
        selectedList = create('ul', 'picker-selected');
        root.appendChild(selectedList);
      }
      trigger.addEventListener('click', function() { open(); });
    }

    function selectedItems() {
      return items.filter(function(item) { return item.option.selected; });
    }

    function refresh() {
      if (inline) {
        items.forEach(function(item) {
          var on = item.option.selected;
          item.chip.setAttribute('aria-checked', on ? 'true' : 'false');
          item.chip.className = 'picker-chip' + (on ? ' is-selected' : '');
        });
        return;
      }

      var chosen = selectedItems();
      var none = chosen.length === 0;
      trigger.className = 'picker-trigger' + (none ? ' is-placeholder' : '');
      triggerText.textContent = multiple || none ? placeholder : chosen[0].label;
      triggerCount.textContent = multiple && !none ? String(chosen.length) : '';
      triggerCount.style.display = multiple && !none ? '' : 'none';

      if (multiple) {
        selectedList.innerHTML = '';
        chosen.forEach(function(item) {
          var entry = create('li', 'picker-selected-item');
          var remove = button('picker-selected-remove');
          remove.setAttribute('aria-label', attr(select, 'remove', 'Remove') + ' ' + item.label);
          remove.appendChild(create('span', 'picker-selected-label', item.label));
          remove.appendChild(icon('times'));
          remove.addEventListener('click', function() {
            item.option.selected = false;
            fireChange(select);
            refresh();
          });
          entry.appendChild(remove);
          selectedList.appendChild(entry);
        });
      }
    }

    // ---- the full-screen sheet
    var sheet = null, lastFocus = null, changedWhileOpen = false;

    function open() {
      if (sheet) { return; }
      if (openPicker && openPicker !== api) { openPicker.close(); }
      openPicker = api;
      lastFocus = document.activeElement;
      changedWhileOpen = false;

      var root = create('div', 'picker-sheet');
      var backdrop = create('div', 'picker-backdrop');
      var panel = create('div', 'picker-panel');
      var header = create('div', 'picker-header');
      var closeButton = button('picker-close');
      var heading = create('h2', 'picker-title', title);
      var list = create('div', 'picker-list');
      var empty = create('p', 'picker-empty', attr(select, 'empty', 'No matches'));
      var doneButton = null, search = null;

      panel.setAttribute('role', 'dialog');
      panel.setAttribute('aria-modal', 'true');
      panel.setAttribute('aria-label', title);
      panel.setAttribute('tabindex', '-1');
      closeButton.setAttribute('aria-label', attr(select, 'close', 'Close'));
      closeButton.appendChild(icon('times'));
      list.setAttribute('role', 'listbox');
      if (multiple) { list.setAttribute('aria-multiselectable', 'true'); }
      empty.style.display = 'none';

      header.appendChild(closeButton);
      header.appendChild(heading);
      if (multiple) {
        doneButton = button('picker-done');
        header.appendChild(doneButton);
      }
      panel.appendChild(header);

      if (items.length > SEARCH_THRESHOLD) {
        var searchRow = create('div', 'picker-search');
        search = create('input', 'picker-search-input');
        search.type = 'search';
        search.placeholder = attr(select, 'search', 'Search');
        search.setAttribute('aria-label', attr(select, 'search', 'Search'));
        search.setAttribute('autocomplete', 'off');
        search.setAttribute('autocapitalize', 'none');
        search.setAttribute('autocorrect', 'off');
        search.setAttribute('spellcheck', 'false');
        search.setAttribute('enterkeyhint', 'search');
        searchRow.appendChild(search);
        panel.appendChild(searchRow);
        search.addEventListener('input', function() { render(search.value); });
      }

      panel.appendChild(list);
      panel.appendChild(empty);
      root.appendChild(backdrop);
      root.appendChild(panel);
      document.body.appendChild(root);
      lockScroll(true);
      trigger.setAttribute('aria-expanded', 'true');

      function updateDone() {
        if (!doneButton) { return; }
        var count = selectedItems().length;
        doneButton.textContent = attr(select, 'done', 'Done') + (count ? ' (' + count + ')' : '');
      }

      function render(query) {
        var needle = fold(query);
        var shown = 0;
        list.innerHTML = '';
        items.forEach(function(item) {
          if (needle && fold(item.label).indexOf(needle) === -1) { return; }
          shown += 1;
          var on = item.option.selected;
          var row = button('picker-option' + (on ? ' is-selected' : ''));
          row.setAttribute('role', 'option');
          row.setAttribute('aria-selected', on ? 'true' : 'false');
          row.appendChild(create('span', 'picker-option-label', item.label));
          row.appendChild(icon(multiple ? 'check-square' : 'check'));
          row.addEventListener('click', function() {
            if (multiple) {
              item.option.selected = !item.option.selected;
              changedWhileOpen = true;
              row.className = 'picker-option' + (item.option.selected ? ' is-selected' : '');
              row.setAttribute('aria-selected', item.option.selected ? 'true' : 'false');
              updateDone();
            } else {
              select.value = item.value;
              fireChange(select);
              refresh();
              close();
            }
          });
          list.appendChild(row);
        });
        empty.style.display = shown ? 'none' : '';
      }

      function focusables() {
        return Array.prototype.slice.call(panel.querySelectorAll('button, input')).filter(function(node) {
          return node.offsetParent !== null;
        });
      }

      function onKey(event) {
        if (event.key === 'Escape' || event.keyCode === 27) {
          event.preventDefault();
          close();
        } else if (event.key === 'Tab' || event.keyCode === 9) {
          var nodes = focusables();
          if (!nodes.length) { return; }
          var first = nodes[0], last = nodes[nodes.length - 1];
          if (event.shiftKey && (document.activeElement === first || document.activeElement === panel)) {
            event.preventDefault();
            last.focus();
          } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first.focus();
          }
        }
      }

      closeButton.addEventListener('click', function() { close(); });
      backdrop.addEventListener('click', function() { close(); });
      if (doneButton) { doneButton.addEventListener('click', function() { close(); }); }
      document.addEventListener('keydown', onKey, true);

      sheet = { root: root, onKey: onKey };
      render('');
      updateDone();

      // On a phone, focusing the search box would pop the keyboard over the
      // list before anyone has seen it, so only do that with a mouse.
      if (search && !prefersTouchKeyboard()) { search.focus(); } else { panel.focus(); }
    }

    function close() {
      if (!sheet) { return; }
      document.removeEventListener('keydown', sheet.onKey, true);
      if (sheet.root.parentNode) { sheet.root.parentNode.removeChild(sheet.root); }
      sheet = null;
      lockScroll(false);
      trigger.setAttribute('aria-expanded', 'false');
      if (multiple && changedWhileOpen) { fireChange(select); }
      refresh();
      if (openPicker === api) { openPicker = null; }
      if (lastFocus && lastFocus.focus) { lastFocus.focus(); } else { trigger.focus(); }
    }

    var api = { refresh: refresh, close: close };
    select.__touchPicker = api;

    // Existing code sets values programmatically and then signals Chosen.
    if (window.jQuery) { window.jQuery(select).on('chosen:updated', refresh); }
    select.addEventListener('change', refresh);
    refresh();
  }

  function enhanceAll(scope) {
    var selects = (scope || document).querySelectorAll('select[data-touch-picker]');
    Array.prototype.forEach.call(selects, enhance);
  }

  function refreshAll(scope) {
    var selects = (scope || document).querySelectorAll('select[data-picker-ready]');
    Array.prototype.forEach.call(selects, function(select) {
      if (select.__touchPicker) { select.__touchPicker.refresh(); }
    });
  }

  window.TouchPicker = {
    shouldUse: shouldUse,
    enhance: enhance,
    enhanceAll: enhanceAll,
    refreshAll: refreshAll
  };

  function init() {
    if (shouldUse()) { enhanceAll(document); }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
