routes = {}

module.exports =
  push: (route, permission, redirect) ->
  check: (route, params, user) ->
    return ['signin', null] if not user and not ['forgot', 'reset', 'confirm'].includes(route)
    [route, params]