{API} = require 'aws-amplify'
getDatabase = ->
  str = localStorage.getItem('database') or '{}'
  JSON.parse str
saveDatabase = (database) ->
  localStorage.setItem 'database', JSON.stringify database
module.exports =
  getHistory: (type) ->
    database = getDatabase()
    database[type] or []
  getScanned: ->
    database = getDatabase()
    [(database.equipment or [])..., (database.person or [])...]
  pushHistory: (item) ->
    database = getDatabase()
    database[item.type] = database[item.type] or []
    filtered = database[item.type].filter (f) ->
      f.id is item.id
    if not filtered.length
      database[item.type].push item
      saveDatabase database
    else
      throw JSON.stringify filtered
    database[item.type]
  cleanHistory: (items) ->
    database = getDatabase()
    for item in items
      database[item.type] = database[item.type]?.filter (f) ->
        f.id isnt item.id
    saveDatabase database
  removeItem: (id, type) ->
    database = getDatabase()
    database[type] = database[type].filter (f) ->
      f.id isnt id
    saveDatabase database
  addToDatabase: (item1, item2, overrideDate) ->
    item = {}
    item[item1.type] = item1
    item[item2.type] = item2
    item.overrideDate = overrideDate?.toISOString()
    await API.post 'FarmAPI', 'events',
      body: item
  list: (route) ->
    try
      console.log '1a', route
      {body} = await API.get 'FarmAPI', route
      console.log '2a'
      app.offline = false
      return JSON.parse body
    catch e
      if e.message is 'Network Error'
        app.offline = true
      return []
  single: (route) ->
    console.log API
    try
      JSON.parse (await API.get 'FarmAPI', route).body
    catch e
      return null
  post: (route, body) ->
    try
      return await API.post 'FarmAPI', route, body:body
    catch e
      console.log e
    null
  delete: (route) ->
    try
      return await API.del 'FarmAPI', route
    catch e
      console.log e
    null
  listUsers: ->
    await API.listUsers()
