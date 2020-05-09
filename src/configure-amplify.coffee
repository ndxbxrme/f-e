import {Auth, API} from 'aws-amplify'
config = require './config.json'
Auth.configure
  userPoolId: config.cognito.userPoolId
  userPoolWebClientId: config.cognito.userPoolWebClientId
  mandatorySignIn: true
  region: config.cognito.region
API.configure
  endpoints: [
    name: 'FarmAPI'
    endpoint: config.api.url
    custom_header: ->
      Authorization: "Bearer #{(await Auth.currentSession()).getIdToken().getJwtToken()}"
  ]