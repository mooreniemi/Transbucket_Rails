$(document).ready(function(){var e=document.querySelector("#dropper"),n=$(".hide").html();if(Dropzone.autoDiscover=!1,e&&!location.pathname.match(/pins\/new/))var t=new Dropzone("#dropper",{url:"/pin_images",method:"put",maxFilesize:1,previewTemplate:n,paramName:function(e){return"pin_images["+e+"][photo]"},addRemoveLinks:!0,headers:{"X-CSRF-Token":$('meta[name="csrf-token"]').attr("content")},autoProcessQueue:!1,uploadMultiple:!0,parallelUploads:100,maxFiles:10,init:function(){var e=document.querySelector("#submit-all");t=this,e.addEventListener("click",function(){t.processQueue()}),$.getJSON("pin_images.json",function(e){return e&&e.forEach(function(e){t.options.addedfile.call(t,e),$(e.previewElement).prop("id",e.id),$(e.previewElement).children("input").val(e.caption),t.options.thumbnail.call(t,e,e.url)}),$(".dz-preview .caption").on("input",function(){var e=this.parentElement.id;$.ajax({url:"/pin_images/"+e+".json",type:"PUT",data:{id:e,caption:this.value}})}),e})}})});