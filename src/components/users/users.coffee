{API} = require 'aws-amplify'
modal = require '../modal/modal.coffee'
storage = require '../storage/storage.coffee'
alert = require '../alert/alert.coffee'
permissions = require '../permissions/permissions.coffee'
permissions.push 'users', permissions.isAdmin, ['dashboard']
module.exports = ->
  module.exports.onload = =>
    load = ->
      {body} = await API.get 'FarmAPI', 'users'
      tableElm = document.querySelector '.users .table'
      tableElm.innerHTML = require('./table.pug') users:JSON.parse(body), ctrl:
        getAttribute: (user, name) ->
          for attr in user.Attributes
            return attr.Value if attr.Name is name
    load()
    app.invite = ->
      #alert.show 'hey man'
      myobj = await modal.show require('../modal/modal-invite.pug')(), (resolve) ->
        app.cancel = -> resolve {}
        app.inviteSubmit = ->
          try
            myobj = await app.formValidator.validate null, true
            resolve myobj
          catch
            return
      modal.hide()
      if myobj.email
        result = await storage.post 'user', myobj
        if result.statusCode is 200
          alert.show 'User created'
          load()
        else
          alert.show 'Error: ' + result.body
        console.log result