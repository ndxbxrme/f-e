config = require '../../config.json'
module.exports =
  ajaxSuccess: ->
    response = JSON.parse @responseText
    document.querySelector('#image').value = response.public_id + '.' + response.format
    document.querySelector('.uploadImage').src = app.thumbnail document.querySelector('#image').value
    document.querySelector('.uploadImage').className += ' uploaded'
    document.body.className = document.body.className.replace(/ *uploading/, '')
    console.log 'response', response
  upload: ->
    fileElm = document.querySelector('input[type=file]')
    if fileElm.files and fileElm.files.length
      document.body.className = document.body.className.replace(/ *uploading/, '') + ' uploading'
      xhr = new XMLHttpRequest()
      xhr.onload = @ajaxSuccess
      mydata = new FormData()
      mydata.append 'upload_preset', config.cloudinary.uploadPreset
      mydata.append 'file', fileElm.files[0]
      xhr.open 'post', config.cloudinary.url
      xhr.send mydata
  template: require './template.pug'