tinymce.PluginManager.add("contextmenu",function(e){var n,t=e.settings.contextmenu_never_use_native;e.on("contextmenu",function(o){var i;if(!o.ctrlKey||t){if(o.preventDefault(),i=e.settings.contextmenu||"link image inserttable | cell row column deletetable",n)n.show();else{var c=[];tinymce.each(i.split(/[ ,]/),function(n){var t=e.menuItems[n];"|"==n&&(t={text:n}),t&&(t.shortcut="",c.push(t))});for(var a=0;a<c.length;a++)"|"==c[a].text&&(0===a||a==c.length-1)&&c.splice(a,1);n=new tinymce.ui.Menu({items:c,context:"contextmenu"}),n.addClass("contextmenu"),n.renderTo(document.body),e.on("remove",function(){n.remove(),n=null})}var l={x:o.pageX,y:o.pageY};e.inline||(l=tinymce.DOM.getPos(e.getContentAreaContainer()),l.x+=o.clientX,l.y+=o.clientY),n.moveTo(l.x,l.y)}})});