$(document).ready(function(){var e=document.querySelector("#dropper"),n=$(".hide").html();if(Dropzone.autoDiscover=!1,e&&!location.pathname.match(/pins\/new/)){new Dropzone("#dropper",{url:"pin_images",method:"post",maxFilesize:1,previewTemplate:n,paramName:function(e){return"pin_images["+e+"][photo]"},addRemoveLinks:!0,headers:{"X-CSRF-Token":$('meta[name="csrf-token"]').attr("content")},autoProcessQueue:!1,uploadMultiple:!0,parallelUploads:100,maxFiles:10,init:function(){var e=document.querySelector("#submit-all"),n=this;$("#dropper").data("pin-id");e.addEventListener("click",function(){n.processQueue()}),n.on("addedfile",function(e){$("#submit-all").prop("disabled",!1)}),n.on("success",function(e,n){var i=$("#pin_pin_image_ids");i.val(i.val()+","+n.id)}),$.getJSON("pin_images.json",function(e){return e&&e.forEach(function(e){n.options.addedfile.call(n,e),$(e.previewElement).prop("id",e.id),$(e.previewElement).children("input").val(e.caption),n.options.thumbnail.call(n,e,e.url)}),$(".save-caption").on("click",function(e){var n=this.parentElement.id,i=$(this.parentElement).find("input:first"),t=i.val(),a=$(this);$.ajax({url:"/pin_images/"+n+".json",type:"PUT",data:{id:n,caption:t},success:function(){i.css("border-color","green"),a.append("\u2714")}})}),e})}})}});
