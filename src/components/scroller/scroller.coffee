module.exports =
  register: (sel) ->
    lastScrollTop = 0
    elm = document.querySelector sel
    clearScroll = -> document.body.className = document.body.className.replace(/ *scrolled/g, '')
    clearScroll()
    elm.addEventListener 'scroll', (e) ->
      clearScroll()
      document.body.className += " scrolled" if @scrollTop > 20
