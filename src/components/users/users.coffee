{API} = require 'aws-amplify'
module.exports = ->
  console.log 'hey from users'
  {nextToken, ...rest} = await API.get 'AdminQueries', '/listUsers'
  console.log rest