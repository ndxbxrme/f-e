storage = require '../storage/storage.coffee'

module.exports = (params) ->
  module.exports.onload = ->
    events = await storage.list 'events'
    console.log 'ev', events
    tableElm = document.querySelector '.events table'
    tableElm.innerHTML = require('./table' + (if app.isMobile() then '-mobile' else '') + '.pug') items:events