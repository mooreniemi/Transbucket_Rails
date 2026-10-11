// "Reply" on a discussion's home-feed card (pins/_feed_item) links to the
// thread with ?reply_to=<comment id>#comment-<id>. On arrival, open that
// comment's reply box as if its own Reply had been tapped
// (comments/new.js.erb focuses the textarea).
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
$(function() {
  var match = window.location.search.match(/[?&]reply_to=(\d+)/);
  if (!match) { return; }
  var comment = document.getElementById('comment-' + match[1]);
  if (!comment) { return; }
  var actions = comment.querySelector('.comment-actions');
  var reply = actions && actions.querySelector('.comment-reply');
  if (reply) { reply.click(); }
});
