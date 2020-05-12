{BrowserQRCodeReader} = require '@zxing/library'
storage = require '../storage/storage.coffee'
modal = require '../modal/modal.coffee'
codeReader = null

module.exports = (params) ->
  init = ->
    codeReader = new BrowserQRCodeReader()
    app.current = app.current or {}
    redirect = 'scan'
    if /AppleWebKit/.test navigator.userAgent
      #ios stuff
      app.onCleanup ->
        window.webkit.messageHandlers.cameraHandler.postMessage({operation: "stop"})
      document.querySelector('video').style.display = 'none'
      img = document.querySelector '.ios'
      img1 = document.querySelector '.ios1'
      img1.style.display = 'block'
      window.webkit.messageHandlers.cameraHandler.postMessage({operation: "start"})
      getCode = ->
        new Promise (resolve, reject) ->
          app.cameraFrame = (data) ->
            img.src = 'data:image/png;base64,' + data
            img1.src = 'data:image/png;base64,' + data
            setTimeout ->
              try
                myresult = await codeReader.decodeFromImage(img)
                window.webkit.messageHandlers.cameraHandler.postMessage({operation: "stop"}) if myresult
                resolve myresult if myresult
            , 10
      result = await getCode()
      result = JSON.parse result
      #return
    else
      try
        result = await codeReader.decodeOnceFromVideoDevice undefined, 'video'
        result = JSON.parse result
        await codeReader.stopStreams()
        document.querySelector('#video').stop()
      catch e
        document.querySelector('.page').innerHTML = JSON.stringify e
        return
    if result
      modalHtml = require('./scan-result.pug') item:result
      history = storage.getHistory if result.type is 'person' then 'equipment' else 'person'
      console.log 'history length', history?.length
      if history.length is 0
        try
          dbHistory = storage.pushHistory result
          modalHtml = require('./scan-queue.pug') items:dbHistory if dbHistory?.length > 1
          app.current = result
        catch e
          console.log '111111'
          modalHtml = require('./scan-error.pug') error: e
      else if history.length is 1 and not app.riskyScan
        dbResult = JSON.parse (await storage.addToDatabase result, history[0]).body
        storage.cleanHistory [result, history[0]]
        if dbResult.error
          modalHtml = require('./scan-error-attached.pug') dbResult
        else
          modalHtml = require('./scan-success.pug') dbResult
        redirect = 'events'
        app.current = null
      else
        itemHtml = require('./item-select.pug') items:history
        selected = await modal.show itemHtml, (resolve) ->
          app.itemSelect = (itemId) ->
            [myitem] = history.filter (f) -> f.id is itemId
            resolve myitem
          app.itemCancel = ->
            resolve()
        if selected
          dbResult = JSON.parse (await storage.addToDatabase result, selected).body
          storage.cleanHistory [result, selected]
          if dbResult.error
            modalHtml = require('./scan-error-attached.pug') dbResult
          else
            modalHtml = require('./scan-success.pug') dbResult
          redirect = 'events'
          app.current = null
          app.riskyScan = true
          historyEquipment = storage.getHistory 'equipment'
          historyPeople = storage.getHistory 'people'
          app.riskyScan = false if historyPeople.length + historyEquipment.length is 0
        else
          try
            dbHistory = storage.pushHistory result
            modalHtml = require('./scan-queue.pug') items:dbHistory if dbHistory?.length > 1
            app.current = result
          catch e
            console.log '22222'
            modalHtml = require('./scan-error.pug') error: e
    else
      console.log '333333'
      modalHtml = require('./scan-error.pug') error: 'Cannot acces camera.'
      redirect = ''
    await modal.show modalHtml, (resolve) -> setTimeout resolve, 3000
    modal.hide()
    app.goto redirect
  module.exports.onload = ->
    setTimeout init
