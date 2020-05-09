validators =
  required: (elem) ->
    console.log elem.name, elem.value
    elem.value
  invalid: (elem) ->
    false
  confirm: (elem) ->
    elem.value is document.querySelector('input[name=' + elem.name.replace('Confirm', '') + ']').value
  password: (elem) ->
    /[A-Z]/.test(elem.value) and /[a-z]/.test(elem.value) and /[^0-9^a-z]/i.test(elem.value) and elem.value.length > 7
module.exports =
  validate: (event, shouldThrow) ->
    console.log 'validating', shouldThrow
    form = document.querySelector 'form'
    output = {}
    truth = true
    errors = []
    for elem in form.elements
      if elem.name
        output[elem.name] = elem.value
        output[elem.name] = +output[elem.name] if elem.type is 'number'
        localTruth = true
        for name in elem.getAttributeNames()
          if validators[name]
            validatorTruth = validators[name](elem)
            localTruth = localTruth and validatorTruth
            errors.push elem.name + '-' + name if not validatorTruth
            continue if not localTruth
        truth = truth and localTruth
    form.querySelectorAll('.error').forEach (elem) ->
      elem.className = elem.className.replace(/ *invalid/g, '')
    if truth
      form.className = form.className.replace(/ *invalid/g, '')
    else
      form.className = form.className.replace(/ *invalid/g, '') + ' invalid'
      for error in errors
        console.log 'error', error
        elem = document.querySelector '.error.' + error
        elem.className += ' invalid' if elem
      if shouldThrow
        throw 'invalid'
    output
  init: ->
    form = document.querySelector 'form'
    for elem in form.elements
      if elem.name
        elem.onchange = @.validate
        elem.onkeyup = @.validate
    @.validate()