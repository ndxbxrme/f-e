routes = {}

module.exports =
  push: (route, permission, redirect) ->
    routes[route] =
      permission: permission
      redirect: redirect
  isAdmin: -> app.user?.groups?.includes 'Admin'
  check: (route, params, user) ->
    console.log 'check permissions'
    if myroute = routes[route]
      console.log 'got route', myroute
      return [route, params] if myroute.permission()
      [route, params] = myroute.redirect
    return ['signin', null] if not user and not ['forgot', 'reset', 'confirm'].includes(route)
    [route, params]