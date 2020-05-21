{API} = require 'aws-amplify'
module.exports = ->
  module.exports.onload = =>
    {body} = await API.get 'FarmAPI', 'users'
    tableElm = document.querySelector '.users .table'
    tableElm.innerHTML = require('./table.pug') users:JSON.parse(body), ctrl:
      getAttribute: (user, name) ->
        for attr in user.Attributes
          return attr.Value if attr.Name is name