storage = require '../storage/storage.coffee'

module.exports = (params) ->
  module.exports.onload = ->
    equipment = await storage.list 'equipment'
    needsMaintenance = equipment.filter (item) ->
      item.needsMaintenance = item.currentTime / 1000 / 60 / 60 > item.schedule * 80 / 100
      item.needsMaintenance
    tableElm = document.querySelector '.equipment-list table'
    tableElm.innerHTML = require('./table.pug') 
      items:equipment
      needsMaintenance: needsMaintenance
    app.search = (term) ->
      tableElm.innerHTML = require('./table.pug') items:equipment.filter (equipment) ->
        equipment.name.toLowerCase().includes term.toLowerCase()