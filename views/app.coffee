$ = jQuery

$('#drop').droppable().bind 'drop', (e) ->
    
  $.each e.dataTransfer.files, (index, file) ->
    uploader = new $.uploader('/', file)
    uploader.create()