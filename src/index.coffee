import './index.styl'
import {Auth, API} from 'aws-amplify'
require './configure-amplify.coffee'
window.msToHms = require 'ms-to-hms'
window.msToHm = (time) -> window.msToHms(time).replace(/:\d+$/, '').replace(':', '<sub>h</sub>') + '<sub>m</sub>'

cleanup = []
app = window.app =
  baseURI: document.baseURI.replace(window.location.origin, '')
  useHash: /\.html/.test document.baseURI
  loggedIn: false
  setState: ->
    document.body.className = document.body.className.replace(/ *loaded/g, '') + ' loading'
    await fn() for fn in cleanup
    cleanup = []
    [@route, ...@params] = (if @useHash then window.location.hash.replace('#', '').replace(/^\//, '') else window.location.pathname.replace(@baseURI, '')).split /\//g
    @route = @route or 'dashboard'
    [@route, @params] = @permissions.check @route, @params, app.user
    template = @templates[@route] or @templates.dashboard
    controller = @controllers[@route] or @controllers.dashboard
    document.querySelector('.page').innerHTML = template app: @, ctrl: controller? @params
    await controller.onload?()
    require('./components/scroller/scroller.coffee').register '.body'
    document.body.className = document.body.className.replace(/ *loading/g, '') + ' loaded'
  goto: (route) ->
    if @useHash
      document.location.hash = route
    else
      route = document.baseURI.replace(document.location.origin, '') + route.replace(/^\//, '')
      window.history.pushState route, null, route if route isnt window.location.pathname
    @setState()
  onCleanup: (fn) ->
    cleanup.push fn
  storage: require './components/storage/storage.coffee'
  permissions: require './components/permissions/permissions.coffee'
  isMobile: require 'is-mobile'
require('./components.coffee') app
window.addEventListener 'popstate', -> app.setState()
main = ->
  document.body.className += if app.isMobile() then ' mobile' else ' web'
  try
    app.loggedIn = true if app.user = await Auth.currentAuthenticatedUser()
    app.user.groups = require('jwt-decode')(app.user.signInUserSession.idToken.jwtToken)["cognito:groups"]
  app.setState()
main()
