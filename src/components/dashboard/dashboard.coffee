mobile = require 'is-mobile'
storage = require '../storage/storage.coffee'
Hammer = require 'hammerjs'
modal = require '../modal/modal.coffee'
alert = require '../alert/alert.coffee'

offset = (elm, tosel) ->
  output = left:0, top: 0, width: elm.offsetWidth, height: elm.offsetHeight
  toelm = document.querySelector tosel
  while elm.tagName isnt 'BODY' and elm isnt toelm
    output.left += elm.offsetLeft
    output.top += elm.offsetTop
    elm = elm.parentElement
  output

module.exports = (params) ->
  load = ->
    equipment = await storage.list 'equipment'
    console.log 'eq', equipment
    data = {}
    data.needsMaintenance = equipment.filter (item) ->
      item.scheduleMs = item.schedule * 1000 * 60 * 60
      item.timeLeft = item.scheduleMs - item.currentTime
      item.currentTime > item.scheduleMs * 80 / 100
    data.currentEvents = equipment.filter (item) ->
      item.attachedTo
    data.currentEvents.sort (a, b) -> if a.attachedDate > b.attachedDate then -1 else 1
    if mobile()
      document.querySelector('.dashboard .table').innerHTML = require('./table-mobile.pug') data 
    else
      document.querySelector('.dashboard .table').innerHTML = require('./table.pug') data
  await load()
  mc = new Hammer document.querySelector('.dashboard .table')
  mc.on 'swipeleft swiperight', (ev) ->
    #return if ev.deltaX < -180
    elm = ev.target
    while elm.tagName isnt 'BODY'
      [attr] = elm.getAttributeNames().filter (name) -> /pan|swipe|tap|press/.test name
      if attr
        Array.from(document.querySelectorAll('.panned')).forEach (panned) ->
          panned.className = panned.className.replace(/ *panned/g, '')
        return if ev.type is 'swiperight'
        elm.className += ' panned'
        break
      elm = elm.parentElement
  app.deleteEvent = (id) ->
    [myequipment] = equipment.filter (item) -> item.id is id
    shouldDelete = await modal.show require('../modal/modal-delete-event.pug')(myequipment), (resolve) ->
      app.ok = -> resolve true
      app.cancel = -> resolve false
    modal.hide()
    if shouldDelete
      fpe = '0-' + myequipment.attachedTo.id + '-' + myequipment.id
      result = await storage.delete 'events/' + fpe
      alert.show 'Event deleted'
      load()
  app.signIn = (id) ->
    [myequipment] = equipment.filter (item) -> item.id is id
    myequipment.type = 'equipment'
    await storage.addToDatabase myequipment, myequipment.attachedTo
    alert.show 'Equipment signed in'
    load()
  ###
  {body} = await API.get 'FarmAPI', '/equipment'
  equipment = JSON.parse body
  {body} = await API.get 'FarmAPI', '/people'
  people = JSON.parse body
  tableElm = document.querySelector '.dashboard table'
  tableElm.innerHTML = ''
  for item in [...equipment, ...people]
    tableElm.innerHTML += require('./table-row.pug') item
  ###