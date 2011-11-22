$ = jQuery

$.event.props.push('dataTransfer')

ondragenter = (e) ->
  $(e.target).addClass('active')
  false
 
ondragover = (e) ->
  e.dataTransfer.dropEffect = 'copy'
  false
  
ondragleave = (e) ->
  $(e.target).removeClass('active')
  false
  
ondrop = (e) ->
  $(e.target).removeClass('active')
  false
  
$.fn.droppable = ->
  this.bind('dragenter', ondragenter).
       bind('dragover', ondragover).
       bind('dragleave', ondragleave).
       bind('drop', ondrop)
  
$ ->
  $(document.body).bind('dragover', (e) -> false)