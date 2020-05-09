storage = require '../storage/storage.coffee'
pad = (n) ->
  ('00' + n).substr n.toString().length
module.exports =
  fetchEvents: (id) ->
    events = await storage.list 'events-search/' + id
    eventsByMonth = {}
    eventsByEquipment = {}
    eventsByPerson = {}
    today = new Date()
    lastDate = new Date(today.getFullYear() - 1, today.getMonth(), 1)
    while today > lastDate
      eventsByMonth[lastDate.getFullYear() + '-' + pad(lastDate.getMonth() + 1)] =
        time: 0
        events: 0
      lastDate = new Date(lastDate.getFullYear(), lastDate.getMonth() + 1, lastDate.getDate())
    events.forEach (event) ->
      started = new Date(event.started)
      month = eventsByMonth[started.getFullYear() + '-' + pad(started.getMonth() + 1)]
      if event.finished isnt '0'
        if month 
          month.events++
          month.time += new Date(event.finished).getTime() - new Date(event.started).getTime()
        myEbq = eventsByEquipment[event.equipment.id] = eventsByEquipment[event.equipment.id] or
          equipment: event.equipment
          time: 0
          events: 0
        myEbq.events++
        myEbq.time += new Date(event.finished).getTime() - new Date(event.started).getTime()
        myEbp = eventsByPerson[event.person.id] = eventsByPerson[event.person.id] or
          person: event.person
          time: 0
          events: 0
        myEbp.events++
        myEbp.time += new Date(event.finished).getTime() - new Date(event.started).getTime()
    maxTime = 0
    maxTime = Math.max(maxTime, month.time) for key, month of eventsByMonth
    month.percent = month.time / maxTime * 100 for key, month of eventsByMonth
    maxTime = 0
    maxTime = Math.max(maxTime, ebq.time) for key, ebq of eventsByEquipment
    ebq.percent = ebq.time / maxTime * 100 for key, ebq of eventsByEquipment
    eventsByEquipment = Object.values(eventsByEquipment).sort (a, b) -> if a.time > b.time then -1 else 1
    document.querySelector('.chart-month')?.innerHTML = require('./chart-month.pug') items: eventsByMonth
    document.querySelector('.chart-equipment')?.innerHTML = require('./chart-equipment.pug') items: eventsByEquipment
    document.querySelector('.chart-people')?.innerHTML = require('./chart-people.pug') items: eventsByPerson