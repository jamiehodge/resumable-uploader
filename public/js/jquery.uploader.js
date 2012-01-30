var $, Upload;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
$ = jQuery;
Upload = (function() {
  function Upload(element) {
    this.element = element;
    this.put = __bind(this.put, this);
    this.head = __bind(this.head, this);
    this.post = __bind(this.post, this);
    this.resume = __bind(this.resume, this);
    this.create = __bind(this.create, this);
    this.progress = __bind(this.progress, this);
    if (!(window.File && window.FileReader && window.FileList && window.Blob)) {
      return;
    }
    this.bufferSize = 1024 * 1024 * 20;
    this.pos = 0;
    this.form = $(this.element);
    this.form.after($('<progress />').attr({
      'max': 1,
      'value': 0,
      'id': 'progress'
    }));
    if (this.form.hasClass('create')) {
      this.form.bind({
        'submit': this.post
      });
    }
    if (this.form.hasClass('resume')) {
      this.form.bind({
        'submit': this.resume
      });
    }
  }
  Upload.prototype.file = function() {
    return $('input:file', this.form)[0].files[0];
  };
  Upload.prototype.slice = function() {
    return this.file().webkitSlice || this.file().mozSlice || this.file().slice;
  };
  Upload.prototype.blob = function() {
    return this.slice().call(this.file(), this.startByte(), this.stopByte());
  };
  Upload.prototype.blobSize = function() {
    return Math.min(this.bufferSize, this.file().size - this.startByte());
  };
  Upload.prototype.startByte = function() {
    return this.pos * this.bufferSize;
  };
  Upload.prototype.stopByte = function() {
    return this.startByte() + this.blobSize();
  };
  Upload.prototype.complete = function() {
    return this.startByte() + this.blobSize() === this.file().size;
  };
  Upload.prototype.progress = function(e) {
    var factor, scalar;
    scalar = this.stopByte() / this.file().size;
    factor = Math.round(e.loaded / e.total);
    return $('#progress').attr('value', scalar * factor);
  };
  Upload.prototype.data = function() {
    var data;
    data = new FormData();
    data.append('asset[document_id]', $('input:hidden').val());
    data.append('asset[file][filename]', this.file().name);
    data.append('asset[file][type]', this.file().type);
    data.append('asset[file][size]', this.file().size);
    return data;
  };
  Upload.prototype.create = function(e) {
    e.preventDefault();
    if (this.file()) {
      return this.post(e);
    }
  };
  Upload.prototype.resume = function(e) {
    e.preventDefault();
    if (this.file()) {
      return this.head(this.form.attr('action'));
    }
  };
  Upload.prototype.post = function(e) {
    $.ajax({
      url: $(this.form).attr('action'),
      type: $(this.form).attr('method'),
      data: this.data(),
      processData: false,
      contentType: false,
      cache: false,
      beforeSend: __bind(function(xhr, settings) {
        return xhr.setRequestHeader('Accept', 'application/json');
      }, this),
      success: __bind(function(data, status, xhr) {
        return this.head(xhr.getResponseHeader('Location'));
      }, this)
    });
    return false;
  };
  Upload.prototype.head = function(url) {
    return $.ajax({
      url: url + ("/chunks/" + (this.pos + 1)),
      type: 'HEAD',
      success: __bind(function(data, status, xhr) {
        this.pos += 1;
        return this.head(url);
      }, this),
      error: __bind(function(xhr) {
        return this.put(url);
      }, this)
    });
  };
  Upload.prototype.put = function(url) {
    return $.ajax({
      url: url + ("/chunks/" + (this.pos + 1)),
      type: 'PUT',
      data: this.blob(),
      processData: false,
      contentType: this.file().type,
      cache: false,
      beforeSend: __bind(function(xhr, settings) {
        return xhr.setRequestHeader('Accept', 'application/json');
      }, this),
      xhr: __bind(function() {
        var xhr;
        xhr = $.ajaxSettings.xhr();
        xhr.upload.addEventListener('progress', this.progress, false);
        return xhr;
      }, this),
      success: __bind(function(data, status, xhr) {
        if (!this.complete()) {
          this.pos += 1;
          return this.head(url);
        } else {
          return window.location.href = url;
        }
      }, this),
      error: __bind(function(xhr) {
        return this.head(url);
      }, this)
    });
  };
  return Upload;
})();
$.fn.uploader = function() {
  return this.each(function() {
    return new Upload(this);
  });
};