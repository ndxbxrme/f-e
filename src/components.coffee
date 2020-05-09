mobile = require 'is-mobile'
module.exports = (app) ->
  Object.assign app,
    templates:
      signin: require('./components/signin/signin.pug')
      dashboard: require('./components/dashboard/dashboard.pug')
      header: require('./components/header/header.pug')
      nav: require('./components/nav/nav.pug')
      equipment: require('./components/equipment/equipment.pug')
      "equipment-list": require('./components/equipment-list/equipment-list.pug')
      people: require('./components/people/people.pug')
      person: require('./components/person/person.pug')
      events: require('./components/events/events.pug')
      scanned: require('./components/scanned/scanned.pug')
      #simulator: require('./components/simulator/simulator.pug')
    controllers:
      signin: require('./components/signin/signin.coffee')
      dashboard: require('./components/dashboard/dashboard.coffee')
      equipment: require('./components/equipment/equipment.coffee')
      "equipment-list": require('./components/equipment-list/equipment-list.coffee')
      people: require('./components/people/people.coffee')
      person: require('./components/person/person.coffee')
      scan: require('./components/scan/scan.coffee')
      events: require('./components/events/events.coffee')
      scanned: require('./components/scanned/scanned.coffee')
      #simulator: require('./components/simulator/simulator.coffee')
    imageUploader: require('./components/image-uploader/image-uploader.coffee')
    formValidator: require('./components/form-validator/form-validator.coffee')
    passwordValidator: require('./components/form-validator/password.coffee')
    thumbnail: require('./components/thumbnail/thumbnail.coffee')
    schedule: require('./components/schedule/schedule.coffee')
    dateFormat: require('./components/date-format/date-format.coffee')
    version: require('../package.json').version
  if mobile()
    app.templates = {
      ...app.templates,
      dashboard: require('./components/dashboard/dashboard-mobile.pug')
      nav: require('./components/nav/nav-mobile.pug')
      header: require('./components/header/header-mobile.pug')
      scan: require('./components/scan/scan-mobile.pug')
      people: require('./components/people/people-mobile.pug')
      person: require('./components/person/person-mobile.pug')
      "equipment-list": require('./components/equipment-list/equipment-list-mobile.pug')
      events: require('./components/events/events-mobile.pug')
      equipment: require('./components/equipment/equipment-mobile.pug')
    }
  console.log app