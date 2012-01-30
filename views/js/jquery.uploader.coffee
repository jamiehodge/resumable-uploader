$ = jQuery

class Upload

  constructor: (@element) ->
    
    return unless window.File && window.FileReader && window.FileList && window.Blob
    
    @bufferSize = 1024 * 1024 * 20
    @pos = 0
    @form = $(@element)
    @form.after $('<progress />').attr
      'max': 1
      'value': 0
      'id': 'progress'
    
    if @form.hasClass('create')
      @form.bind
        'submit' : @post
    
    if @form.hasClass('resume')
      @form.bind
        'submit' : @resume
    
  file: ->
    $('input:file', @form)[0].files[0]

  slice: ->
    @file().webkitSlice || @file().mozSlice || @file().slice

  blob: ->
    @slice().call @file(), @startByte(), @stopByte()
  blobSize: ->
    Math.min(@bufferSize, @file().size - @startByte())
    
  startByte: ->
    @pos * @bufferSize
  stopByte: ->
    @startByte() + @blobSize()
  
  complete: ->
    @startByte() + @blobSize() == @file().size
    
  progress: (e) =>
    scalar = (@stopByte() / @file().size)
    factor = Math.round((e.loaded / e.total))
    $('#progress').attr('value', scalar * factor)
      
  data: ->
    data = new FormData()
    data.append('asset[document_id]', $('input:hidden').val())
    data.append('asset[file][filename]', @file().name)
    data.append('asset[file][type]', @file().type)
    data.append('asset[file][size]', @file().size)
    data
    
  create: (e) =>
    e.preventDefault()
    @post(e) if @file()
    
  resume: (e) =>
    e.preventDefault()
    @head(@form.attr('action')) if @file()
    
  post: (e) =>
    $.ajax
      url:          $(@form).attr('action')
      type:         $(@form).attr('method')
      data:         @data()
      processData:  false
      contentType:  false
      cache:        false
      beforeSend:   (xhr, settings) =>
        xhr.setRequestHeader('Accept', 'application/json')
      success:      (data, status, xhr) =>
        @head(xhr.getResponseHeader('Location'))
    false
      
  head: (url) =>
    $.ajax
      url:          url + "/chunks/#{@pos + 1}"
      type:         'HEAD'
      success:      (data, status, xhr) =>
        @pos += 1
        @head(url)
      error:        (xhr) =>
        @put(url)
      
  put: (url) =>
    $.ajax
      url:          url + "/chunks/#{@pos + 1}"
      type:         'PUT'
      data:         @blob()
      processData:  false
      contentType:  @file().type
      cache:        false
      beforeSend:   (xhr, settings) =>
        xhr.setRequestHeader('Accept', 'application/json')
      xhr:          =>
        xhr = $.ajaxSettings.xhr()
        xhr.upload.addEventListener 'progress', @progress, false
        xhr
      success:      (data, status, xhr) =>
        unless @complete()
          @pos += 1
          @head(url)
        else
          window.location.href = url
      error:        (xhr) =>
        @head(url)
        
$.fn.uploader = ->
  this.each ->
    new Upload(this)