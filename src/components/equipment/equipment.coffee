QRCode = require 'qrcode'
storage = require '../storage/storage.coffee'
charts = require '../charts/charts.coffee'
modal = require '../modal/modal.coffee'

controller = (params) ->
  controller.onload = ->
    equipment = await storage.single('equipment/' + params[0]) if params[0]
    body = document.querySelector '.body'
    if equipment
      body.innerHTML = require('./details.pug') item: equipment
      qrEquipment =
        id:equipment.id
        name:equipment.name
        image:equipment.image
        type:'equipment'
      QRCode.toCanvas document.querySelector('.qrcode'), JSON.stringify(qrEquipment)
      setTimeout -> charts.fetchEvents equipment.id
    else
      body.innerHTML = require('./edit.pug') item: {}
    app.edit = ->
      body.innerHTML = require('./edit.pug') item: equipment
    app.submit = ->
      try
        myobj = await app.formValidator.validate()
      catch e
        return
      result = await storage.post 'equipment/' + (params[0] or ''), myobj
    app.maintenance = ->
      result = await storage.post 'equipment/' + (params[0]) + '/maintenance', equipment: equipment
      app.goto 'equipment-list'
    app.delete = ->
      shouldDelete = await modal.show require('../modal/modal-delete.pug')(equipment), (resolve) ->
        app.ok = -> resolve true
        app.cancel = -> resolve false
      modal.hide()
      if shouldDelete
        result = await storage.delete 'equipment/' + params[0]
        app.goto 'equipment-list'
module.exports = controller