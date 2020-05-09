holder = document.createElement 'div'
holder.className = 'modal-holder'
holder.innerHTML += require('./modal.pug')()
document.body.appendChild holder
module.exports =
  setContent: (content) ->
  show: (content, controller) ->
    new Promise (resolve, reject) ->
      modalWindow = holder.querySelector '.modal-window'
      modalWindow.innerHTML = content
      controller? resolve, reject
      holder.style.display = 'block'
  hide: ->
    holder.style.display = 'none'