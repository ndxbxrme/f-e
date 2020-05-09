storage = require '../storage/storage.coffee'

module.exports = (params) ->
  module.exports.onload = ->
    people = await storage.list 'people'
    tableElm = document.querySelector '.people table'
    tableElm.innerHTML = require('./table.pug') items:people
    app.search = (term) ->
      tableElm.innerHTML = require('./table.pug') items:people.filter (person) ->
        person.name.toLowerCase().includes term.toLowerCase()