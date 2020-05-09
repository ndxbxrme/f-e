storage = require '../storage/storage.coffee'
charts = require '../charts/charts.coffee'
QRCode = require 'qrcode'

controller = (params) ->
  controller.onload = ->
    person = await storage.single 'people/' + params[0] if params[0]
    body = document.querySelector '.body'
    console.log 'person', person
    if person
      body.innerHTML = require('./details.pug') item: person
      qrPerson =
        id:person.id
        name:person.name
        image:person.image
        type:'person'
      QRCode.toCanvas document.querySelector('.qrcode'), JSON.stringify(qrPerson)

      setTimeout -> charts.fetchEvents person.id
    else
      body.innerHTML = require('./edit.pug') item: {}
    app.edit = ->
      body.innerHTML = require('./edit.pug') item: person
    app.submit = ->
      try
        myobj = await app.formValidator.validate()
      catch e
        return
      result = await storage.post 'people/' + (params[0] or ''), myobj
      app.goto 'people'
    app.delete = ->
      shouldDelete = await modal.show require('../modal/modal-delete.pug')(person), (resolve) ->
        app.ok = -> resolve true
        app.cancel = -> resolve false
      modal.hide()
      if shouldDelete
        result = await storage.delete 'people/' + params[0]
        app.goto 'people'
module.exports = controller
    