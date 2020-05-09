storage = require '../storage/storage.coffee'

module.exports = (params) ->
  module.exports.onload = ->
    events = await storage.list 'events'
    tableElm = document.querySelector '.events table'
    tableElm.innerHTML = require('./table.pug') items:events