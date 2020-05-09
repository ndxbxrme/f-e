storage = require '../storage/storage.coffee'

module.exports = (params) ->
  app.select = (id) ->
  app.remove = (id, type) ->
    storage.removeItem id, type
    document.querySelector('.page').innerHTML = require('./scanned.pug')()