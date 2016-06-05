tinymce.PluginManager.add("lists",function(a){function b(a){return a&&/^(OL|UL|DL)$/.test(a.nodeName)}function c(a){return a.parentNode.firstChild==a}function d(a){return a.parentNode.lastChild==a}function e(b){return b&&!!a.schema.getTextBlockElements()[b.nodeName]}var f=this;a.on("init",function(){function g(a,b){var c=w.isEmpty(a);return b&&w.select("span[data-mce-type=bookmark]").length>0?!1:c}function h(a){function b(b){var d,e,f;e=a[b?"startContainer":"endContainer"],f=a[b?"startOffset":"endOffset"],1==e.nodeType&&(d=w.create("span",{"data-mce-type":"bookmark"}),e.hasChildNodes()?(f=Math.min(f,e.childNodes.length-1),b?e.insertBefore(d,e.childNodes[f]):w.insertAfter(d,e.childNodes[f])):e.appendChild(d),e=d,f=0),c[b?"startContainer":"endContainer"]=e,c[b?"startOffset":"endOffset"]=f}var c={};return b(!0),a.collapsed||b(),c}function i(a){function b(b){function c(a){for(var b=a.parentNode.firstChild,c=0;b;){if(b==a)return c;(1!=b.nodeType||"bookmark"!=b.getAttribute("data-mce-type"))&&c++,b=b.nextSibling}return-1}var d,e,f;d=f=a[b?"startContainer":"endContainer"],e=a[b?"startOffset":"endOffset"],d&&(1==d.nodeType&&(e=c(d),d=d.parentNode,w.remove(f)),a[b?"startContainer":"endContainer"]=d,a[b?"startOffset":"endOffset"]=e)}b(!0),b();var c=w.createRng();c.setStart(a.startContainer,a.startOffset),a.endContainer&&c.setEnd(a.endContainer,a.endOffset),x.setRng(c)}function j(b,c){var d,e,f,g=w.createFragment(),h=a.schema.getBlockElements();if(a.settings.forced_root_block&&(c=c||a.settings.forced_root_block),c&&(e=w.create(c),e.tagName===a.settings.forced_root_block&&w.setAttribs(e,a.settings.forced_root_block_attrs),g.appendChild(e)),b)for(;d=b.firstChild;){var i=d.nodeName;f||"SPAN"==i&&"bookmark"==d.getAttribute("data-mce-type")||(f=!0),h[i]?(g.appendChild(d),e=null):c?(e||(e=w.create(c),g.appendChild(e)),e.appendChild(d)):g.appendChild(d)}return a.settings.forced_root_block?f||tinymce.Env.ie&&!(tinymce.Env.ie>10)||e.appendChild(w.create("br",{"data-mce-bogus":"1"})):g.appendChild(w.create("br")),g}function k(){return tinymce.grep(x.getSelectedBlocks(),function(a){return/^(LI|DT|DD)$/.test(a.nodeName)})}function l(a,b,c){function d(a){tinymce.each(h,function(c){a.parentNode.insertBefore(c,b.parentNode)}),w.remove(a)}var e,f,h,i;for(h=w.select('span[data-mce-type="bookmark"]',a),c=c||j(b),e=w.createRng(),e.setStartAfter(b),e.setEndAfter(a),f=e.extractContents(),i=f.firstChild;i;i=i.firstChild)if("LI"==i.nodeName&&w.isEmpty(i)){w.remove(i);break}w.isEmpty(f)||w.insertAfter(f,a),w.insertAfter(c,a),g(b.parentNode)&&d(b.parentNode),w.remove(b),g(a)&&w.remove(a)}function m(a){var c,d;if(c=a.nextSibling,c&&b(c)&&c.nodeName==a.nodeName){for(;d=c.firstChild;)a.appendChild(d);w.remove(c)}if(c=a.previousSibling,c&&b(c)&&c.nodeName==a.nodeName){for(;d=c.firstChild;)a.insertBefore(d,a.firstChild);w.remove(c)}}function n(a){tinymce.each(tinymce.grep(w.select("ol,ul",a)),function(a){var c,d=a.parentNode;"LI"==d.nodeName&&d.firstChild==a&&(c=d.previousSibling,c&&"LI"==c.nodeName&&(c.appendChild(a),g(d)&&w.remove(d))),b(d)&&(c=d.previousSibling,c&&"LI"==c.nodeName&&c.appendChild(a))})}function o(a){function e(a){g(a)&&w.remove(a)}var f,h=a.parentNode,i=h.parentNode;return"DD"==a.nodeName?(w.rename(a,"DT"),!0):c(a)&&d(a)?("LI"==i.nodeName?(w.insertAfter(a,i),e(i),w.remove(h)):b(i)?w.remove(h,!0):(i.insertBefore(j(a),h),w.remove(h)),!0):c(a)?("LI"==i.nodeName?(w.insertAfter(a,i),a.appendChild(h),e(i)):b(i)?i.insertBefore(a,h):(i.insertBefore(j(a),h),w.remove(a)),!0):d(a)?("LI"==i.nodeName?w.insertAfter(a,i):b(i)?w.insertAfter(a,h):(w.insertAfter(j(a),h),w.remove(a)),!0):("LI"==i.nodeName?(h=i,f=j(a,"LI")):f=b(i)?j(a,"LI"):j(a),l(h,a,f),n(h.parentNode),!0)}function p(a){function c(c,d){var e;if(b(c)){for(;e=a.lastChild.firstChild;)d.appendChild(e);w.remove(c)}}var d,e;return"DT"==a.nodeName?(w.rename(a,"DD"),!0):(d=a.previousSibling,d&&b(d)?(d.appendChild(a),!0):d&&"LI"==d.nodeName&&b(d.lastChild)?(d.lastChild.appendChild(a),c(a.lastChild,d.lastChild),!0):(d=a.nextSibling,d&&b(d)?(d.insertBefore(a,d.firstChild),!0):d&&"LI"==d.nodeName&&b(a.lastChild)?!1:(d=a.previousSibling,d&&"LI"==d.nodeName?(e=w.create(a.parentNode.nodeName),d.appendChild(e),e.appendChild(a),c(a.lastChild,e),!0):!1)))}function q(){var b=k();if(b.length){for(var c=h(x.getRng(!0)),d=0;d<b.length&&(p(b[d])||0!==d);d++);return i(c),a.nodeChanged(),!0}}function r(){var b=k();if(b.length){var c,d,e=h(x.getRng(!0)),f=a.getBody();for(c=b.length;c--;)for(var g=b[c].parentNode;g&&g!=f;){for(d=b.length;d--;)if(b[d]===g){b.splice(c,1);break}g=g.parentNode}for(c=0;c<b.length&&(o(b[c])||0!==c);c++);return i(e),a.nodeChanged(),!0}}function s(c){function d(){function b(a){var b,c;for(b=f[a?"startContainer":"endContainer"],c=f[a?"startOffset":"endOffset"],1==b.nodeType&&(b=b.childNodes[Math.min(c,b.childNodes.length-1)]||b);b.parentNode!=g;){if(e(b))return b;if(/^(TD|TH)$/.test(b.parentNode.nodeName))return b;b=b.parentNode}return b}for(var c,d=[],g=a.getBody(),h=b(!0),i=b(),j=[],k=h;k&&(j.push(k),k!=i);k=k.nextSibling);return tinymce.each(j,function(a){if(e(a))return d.push(a),void(c=null);if(w.isBlock(a)||"BR"==a.nodeName)return"BR"==a.nodeName&&w.remove(a),void(c=null);var b=a.nextSibling;return tinymce.dom.BookmarkManager.isBookmarkNode(a)&&(e(b)||!b&&a.parentNode==g)?void(c=null):(c||(c=w.create("p"),a.parentNode.insertBefore(c,a),d.push(c)),void c.appendChild(a))}),d}var f=x.getRng(!0),g=h(f),j="LI";c=c.toUpperCase(),"DL"==c&&(j="DT"),tinymce.each(d(),function(a){var d,e;e=a.previousSibling,e&&b(e)&&e.nodeName==c?(d=e,a=w.rename(a,j),e.appendChild(a)):(d=w.create(c),a.parentNode.insertBefore(d,a),d.appendChild(a),a=w.rename(a,j)),m(d)}),i(g)}function t(){var c=h(x.getRng(!0)),d=a.getBody();tinymce.each(k(),function(a){var c,e;if(g(a))return void o(a);for(c=a;c&&c!=d;c=c.parentNode)b(c)&&(e=c);l(e,a)}),i(c)}function u(a){var b=w.getParent(x.getStart(),"OL,UL,DL");if(b)if(b.nodeName==a)t(a);else{var c=h(x.getRng(!0));m(w.rename(b,a)),i(c)}else s(a)}function v(b){return function(){var c=w.getParent(a.selection.getStart(),"UL,OL,DL");return c&&c.nodeName==b}}var w=a.dom,x=a.selection;f.backspaceDelete=function(c){function d(b,c){var d,e,f=b.startContainer,g=b.startOffset;if(3==f.nodeType&&(c?g<f.data.length:g>0))return f;for(d=a.schema.getNonEmptyElements(),e=new tinymce.dom.TreeWalker(b.startContainer);f=e[c?"next":"prev"]();){if("LI"==f.nodeName&&!f.hasChildNodes())return f;if(d[f.nodeName])return f;if(3==f.nodeType&&f.data.length>0)return f}}function e(a,c){var d,e,f=a.parentNode;if(b(c.lastChild)&&(e=c.lastChild),d=c.lastChild,d&&"BR"==d.nodeName&&a.hasChildNodes()&&w.remove(d),g(c,!0)&&w.$(c).empty(),!g(a,!0))for(;d=a.firstChild;)c.appendChild(d);e&&c.appendChild(e),w.remove(a),g(f)&&w.remove(f)}if(x.isCollapsed()){var f=w.getParent(x.getStart(),"LI");if(f){var j=x.getRng(!0),k=w.getParent(d(j,c),"LI");if(k&&k!=f){var l=h(j);return c?e(k,f):e(f,k),i(l),!0}if(!k&&!c&&t(f.parentNode.nodeName))return!0}}},a.on("BeforeExecCommand",function(b){var c,d=b.command.toLowerCase();return"indent"==d?q()&&(c=!0):"outdent"==d&&r()&&(c=!0),c?(a.fire("ExecCommand",{command:b.command}),b.preventDefault(),!0):void 0}),a.addCommand("InsertUnorderedList",function(){u("UL")}),a.addCommand("InsertOrderedList",function(){u("OL")}),a.addCommand("InsertDefinitionList",function(){u("DL")}),a.addQueryStateHandler("InsertUnorderedList",v("UL")),a.addQueryStateHandler("InsertOrderedList",v("OL")),a.addQueryStateHandler("InsertDefinitionList",v("DL")),a.on("keydown",function(b){9!=b.keyCode||tinymce.util.VK.metaKeyPressed(b)||a.dom.getParent(a.selection.getStart(),"LI,DT,DD")&&(b.preventDefault(),b.shiftKey?r():q())})}),a.addButton("indent",{icon:"indent",title:"Increase indent",cmd:"Indent",onPostRender:function(){var b=this;a.on("nodechange",function(){for(var d=a.selection.getSelectedBlocks(),e=!1,f=0,g=d.length;!e&&g>f;f++){var h=d[f].nodeName;e="LI"==h&&c(d[f])||"UL"==h||"OL"==h||"DD"==h}b.disabled(e)})}}),a.on("keydown",function(a){a.keyCode==tinymce.util.VK.BACKSPACE?f.backspaceDelete()&&a.preventDefault():a.keyCode==tinymce.util.VK.DELETE&&f.backspaceDelete(!0)&&a.preventDefault()})});
