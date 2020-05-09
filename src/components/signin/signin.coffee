{Auth} = require 'aws-amplify'
formValidator = require '../form-validator/form-validator.coffee'
module.exports = ->
  module.exports.onload = ->
    formValidator.init()
    app.signin = 
      submit: (event) ->
        event.preventDefault()
        document.querySelector('form').className += ' submitted'
        formValidator.submitted = true
        try
          {username, password, newPassword} = formValidator.validate null, true
        catch e
          return
        errorMsg = document.querySelector '.signin .error'
        return errorMsg.innerText = 'Please enter a username and password.' if not (username and password)
        try
          if newPassword
            response = await Auth.completeNewPassword app.user, newPassword
          else
            response = await Auth.signIn username, password
          app.user = response
          console.log 'response', response
          if response.challengeName
            if response.challengeName is 'NEW_PASSWORD_REQUIRED'
              document.querySelector('.new').style.display = 'flex'
              document.querySelector('.newPassword').setAttribute('password', true)
              document.querySelector('.newPasswordConfirm').setAttribute('confirm', true)
          else
            app.loggedIn = true
            app.setState()
        catch e
          errorMsg.innerText = e.message or e
          app.user = null
          app.loggedIn = false