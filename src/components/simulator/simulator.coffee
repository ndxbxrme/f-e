{API} = require 'aws-amplify'
storage = require '../storage/storage.coffee'
sleep = (time) ->
  new Promise (resolve) ->
    setTimeout resolve, time

module.exports = ->
  d = new Date('2019/01/01')
  output = null
  module.exports.onload = ->
    output = document.querySelector '.output'
  console.log d
  equipment = JSON.parse (await API.get('FarmAPI', 'equipment')).body
  people = JSON.parse (await API.get('FarmAPI', 'people')).body
  current = []
  console.log equipment
  main = ->
    while d < new Date()
      d = new Date(d.getTime() + Math.floor(Math.random() * 1 * 60 * 60 * 1000))
      b = Math.random()
      if b > 0.9
        inout = Math.random()
        if inout > 0.53
          eArr = equipment.filter (item) ->
            not item.attached
          pArr = people.filter (item) ->
            not item.attached
          if eArr.length is 0 and pArr.length is 0
            continue
          er = Math.floor(Math.random() * eArr.length)
          pr = Math.floor(Math.random() * pArr.length)
          #console.log er, eArr.length, pr, pArr.length
          eItem = eArr[er]
          pItem = pArr[pr]
          if not eItem or not pItem
            console.log 'BAD', er, eArr.length, pr, pArr.length
            continue
          eItem.attached = true
          pItem.attached = true
          current.push
            started: new Date(d.getTime()).toISOString()
            e: eItem
            p: pItem
          eItem.type = 'equipment'
          pItem.type = 'person'
          myEItem = 
            id: eItem.id
            name: eItem.name
            image: eItem.image
            type: 'equipment'
          myPItem =
            id: pItem.id
            name: pItem.name
            image: pItem.image
            type: 'person'
          dbResult = JSON.parse (await storage.addToDatabase myEItem, myPItem, d).body
          output?.innerHTML = d.toISOString() + ': Signed out: ' + eItem.name + '\n' + output.innerHTML
          #console.log 'signed out1', eItem, pItem
        else
          if current.length
            cItem = current[Math.floor(Math.random() * current.length)]
            finished = new Date(d.getTime()).toISOString()
            eventTime = new Date(finished).getTime() - new Date(cItem.started).getTime()
            cItem.e.totalTime += eventTime
            cItem.e.currentTime += eventTime
            cItem.e.attached = null
            cItem.p.attached = null
            dbResult = JSON.parse (await storage.addToDatabase cItem.e, cItem.p, d).body
            output?.innerHTML = d.toISOString() + ': Signed in: ' + cItem.e.name + '\n' + output.innerHTML
            if cItem.e.currentTime / 1000 / 60 / 60 > cItem.e.schedule
              await API.post 'FarmAPI', 'equipment/' + cItem.e.id + '/maintenance',
                body:
                  overrideDate: d.toISOString()
                  equipment: cItem.e
              console.log 'MAINTENANCE', cItem.e.id
              output?.innerHTML = d.toISOString() + ': Maintenance: ' + cItem.e.name + '\n' + output.innerHTML
              cItem.e.currentTime = 0
            current?.splice current.indexOf(cItem), 1
            #console.log 'signed in', cItem.e, cItem.p
        #console.log d, current.length
  main()