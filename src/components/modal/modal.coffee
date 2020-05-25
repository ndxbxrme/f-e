holder = document.createElement 'div'
holder.className = 'modal-holder'
holder.innerHTML += require('./modal.pug')()
document.body.appendChild holder
module.exports =
  setContent: (content) ->
  show: (content, controller) ->
    console.log 'modal show'
    new Promise (resolve, reject) ->
      modalWindow = document.querySelector '.modal-window'
      modalWindow.innerHTML = content
      controller? resolve, reject
      document.querySelector('.modal-holder').style.display = 'block'
  hide: ->
    document.querySelector('.modal-holder').style.display = 'none'
    modalWindow = document.querySelector '.modal-window'
    modalWindow.innerHTML = ''