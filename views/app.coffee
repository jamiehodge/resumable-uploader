$ = jQuery

$('.drop.create').droppable().bind 'drop', (e) ->
    
  $.each e.dataTransfer.files, (index, file) ->
    uploader = new $.uploader(file)
    uploader.create('/')
    
$('.drop.update').droppable().bind 'drop', (e) ->
    
  file = e.dataTransfer.files[0]
  uploader = new $.uploader(file)
  uploader.update(window.location.href + '/media')