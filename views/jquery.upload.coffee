$ = jQuery

$.uploader = class Uploader

  constructor: (@file) ->
    @slice = @file.webkitSlice || @file.mozSlice || @file.slice
  
  bufferSize: 1024 * 1024
  position: 0
  
  endPosition: ->
    Math.min(@position + @bufferSize - 1, @file.size)
    
  contentRange: ->
    "bytes #{@position}-#{@endPosition()}/#{@file.size}"
  
  blob: ->
    @slice.call(@file, @position, @endPosition())
    
  create: (url) ->
    data = new FormData($('form')[0])
    if @slice
      data.append('file[filename]', @file.name)
      data.append('file[type]', @file.type)
    else
      data.append('file', @file)
    
    $.ajax(
      url: url
      type: 'POST'
      data: data
      processData: false
      contentType: false
      cache: false
      success: (data, status, xhr) =>
        if @slice
          @update(xhr.getResponseHeader('Location') + '/media')
        else
          window.location.href = xhr.getResponseHeader('Location')
    )
    
  head: (url) ->
    $.ajax
      url: url
      type: 'HEAD'
    
  update: (url) ->
    $.ajax
      url: url
      type: 'PUT'
      data: @blob()
      processData: false
      contentType: @file.type
      cache: false
      beforeSend: (xhr, settings) =>
        xhr.setRequestHeader('Content-Range', @contentRange())
        xhr.setRequestHeader('Content-Type', @file.type)
        xhr.setRequestHeader('X-File-Name', @file.name)
      success: (data, status, xhr) =>
        @position = @endPosition()
        if @position < @file.size - 1
          @update(url)
        else
          window.location.href = xhr.getResponseHeader('Location')
      error: (xhr) =>
        @head(url)
          .done((data, status, xhr) =>
            @position = parseInt(xhr.getResponseHeader('Content-Length')) || 0
            if @position < @file.size
              @update(url)
          )
          .fail(@head(url))