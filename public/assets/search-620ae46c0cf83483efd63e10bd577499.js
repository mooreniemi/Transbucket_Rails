$(document).ready(function(){$(function(){var e="/search_terms.json";$("#query").autocomplete({source:e,minLength:3,open:function(){setTimeout(function(){$(".ui-autocomplete").css("z-index",99999999999999)},0)}})})});