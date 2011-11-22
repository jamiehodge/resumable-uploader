$ = jQuery

$.uploader = class Uploader

  constructor: (@url, @file) ->
    @slice = @file.webkitSlice || @file.mozSlice || @file.slice
  
  bufferSize: 1024 * 1024
  position: 0
  
  endPosition: ->
    Math.min(@position + @bufferSize - 1, @file.size)
    
  contentRange: ->
    "bytes #{@position}-#{@endPosition()}/#{@file.size}"
  
  blob: ->
    @slice.call(@file, @position, @endPosition())
      
  stream: ->
    @create()
    
  create: ->
    data = new FormData()
    data.append('name', @file.name)
    data.append('size', @file.size)
    data.append('type', @file.type)
    
    $.ajax(
      url: @url
      type: 'POST'
      data: data
      processData: false
      contentType: false
      cache: false
      success: (data, status, xhr) =>
        @update(xhr.getResponseHeader('Location'))    
    )
    
  update: (url) ->
    $.ajax
      url: url
      type: 'PUT'
      data: @blob()
      processData: false
      contentType: @file.type
      cache: false
      beforeSend: (xhr, settings) =>
        xhr.setRequestHeader('X-File-Name', @file.name)
        xhr.setRequestHeader('X-File-Size', settings.data.size)
        xhr.setRequestHeader('Content-Range', @contentRange())
      statusCode:
        204: (data, status, xhr) ->
          console.log(xhr.getResponseHeader('Location'))
        308: (xhr) =>
          @position = parseInt(xhr.getResponseHeader('Range').split('-')[1])
          if @position < @file.size
            @update(url)
        400: (xhr) =>
          
        