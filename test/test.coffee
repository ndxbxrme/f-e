localServer = require 'local-web-server'
puppeteer = require 'puppeteer'
{record} = require 'puppeteer-recorder'
faker = require 'faker'
fetch = require 'node-fetch'
fs = require 'fs'
path = require 'path'
request = require 'request'
equipment = require './equipment.json'
global.navigator =
  userAgent: 'summat'
browser = null
page = null
ws = null
makeServer = (path) ->
  ws = localServer.create
    port: 23232
    directory: path
    spa: 'index.html'
gotoPage = (path, puppeteerOptions, device) ->
  browser = await puppeteer.launch puppeteerOptions
  context = browser.defaultBrowserContext()
  await context.overridePermissions 'http://localhost:23232', ['camera']
  page = await browser.newPage()
  await page.emulate puppeteer.devices[device] if device
  await page.goto 'http://localhost:23232/' + (path or '')
closePage = ->
  await browser.close()
  ws.server.close()
sleep = (time) ->
  new Promise (resolve) ->
    setTimeout resolve, time
headless =
  headless: false
  args: ['--window-size=800,600']
logIn = (username, password, options, device) ->
  new Promise (resolve) ->
    await gotoPage '', options, device
    await page.type '.username', username
    await page.type '.password', password
    await page.click 'input[type=submit]'
    await sleep 1000
    resolve()
dateStr = (d) ->
  ('00' + d.getDate()).substr(d.getDate().toString().length) + (d.getMonth() + 1) + d.getFullYear()

exports.firstTest =
  ###
  "Should test QR Code reader": (test) ->
    console.log [
      '--use-fake-device-for-media-stream'
      '--use-file-for-fake-video-capture="' + path.resolve('test/output.webm').replace(/\\\\/g, '\\') + '"'
    ]
    makeServer 'dist'
    await logIn 'kieron', 'Test123!',
      headless: false
      args: [
        '--use-fake-device-for-media-stream'
        '--use-file-for-fake-video-capture="' + path.resolve('test/output.webm').replace(/\\\\/g, '\\') + '"'
      ]
    , 'Pixel 2'
    await page.waitForSelector 'body.loaded'
    await page.goto 'http://localhost:23232/scan'
    await sleep 30000
    test.done()
  "Should test date input": (test) ->
    makeServer 'dist'
    await logIn 'kieron', 'Test123!', headless
    await sleep 4000
    await page.waitForSelector 'body.loaded'
    await page.goto 'http://localhost:23232/equipment-list/'
    await page.waitForSelector 'body.loaded'
    await page.click 'table a:first-of-type'
    await page.waitForSelector 'body.loaded'
    await record
      browser: browser
      page: page
      output: 'test/output.webm'
      fps: 60
      frames: 60 * 30
      prepare: ->
      render: ->
    test.done()
  ###
  "Should add a piece of equipment": (test) ->
    makeServer 'dist'
    await logIn 'kieron', 'Test123!', headless
    i = -1
    while i++ < 20
      await request(equipment[i].img).pipe fs.createWriteStream('test/test.jpg')
      await sleep 2000
      await page.goto 'http://localhost:23232/equipment/'
      await page.waitForSelector 'input[type=file]'
      inputUploadHandle = await page.$ 'input[type=file]'
      fileToUpload = 'test/test.jpg'
      console.log fileToUpload
      inputUploadHandle.uploadFile fileToUpload
      await page.waitForSelector '.uploaded'
      await page.type '.name', equipment[i].name.trim()
      await page.type '.schedule', Math.floor(Math.random() * 80).toString()
      now = new Date().getTime()
      past = now - 356 * 24 * 60 * 60 * 1000
      newDate = new Date(past + Math.random() * (now - past))
      await page.type '.lastMaintenance', '01012019'#dateStr newDate
      await page.click 'input[type=submit]'
      await sleep 1000
      test.equals 0, 0
    test.done()
  "Should add a person": (test) ->
    makeServer 'dist'
    await logIn 'kieron', 'Test123!', headless
    i = 20
    while i-- > 0
      response = await fetch 'https://randomuser.me/api/'
      person = (await response.json()).results[0]
      await request(person.picture.large).pipe fs.createWriteStream('test/test.jpg')
      await sleep 2000
      await page.goto 'http://localhost:23232/person/'
      await page.waitForSelector 'input[type=file]'
      inputUploadHandle = await page.$ 'input[type=file]'
      fileToUpload = 'test/test.jpg'
      console.log fileToUpload
      inputUploadHandle.uploadFile fileToUpload
      await page.waitForSelector '.uploaded'
      await page.type '.name', person.name.first + ' ' + person.name.last
      await page.click 'input[type=submit]'
      await sleep 1000
      test.equals 0, 0
    test.done()
  ###
  "Should simulate events": (test) ->
    makeServer 'dist'
    await logIn 'kieron', 'Test123!', headless
    await page.goto 'http://localhost:23232/simulator'
    await sleep 600000
    test.equals 0, 0
    test.done()
  "Should show login page": (test) ->
    makeServer 'dist'
    await gotoPage ''
    text = await page.evaluate () -> document.querySelector('.page').innerText
    test.equals text, 'login'
    await closePage()
    test.done()
  "Should log in": (test) ->
    makeServer 'dist'
    await gotoPage ''
    await page.type '.username', 'kieron'
    await page.type '.password', 'Test123!'
    await page.click 'input[type=submit]'
    await sleep 1000
    text = await page.evaluate () -> document.querySelector('.dashboard h1').innerText
    test.equals text, 'dashboard kieron'
    await closePage()
    test.done()
  "Should log in and stay logged in": (test) ->
    makeServer 'dist'
    await gotoPage ''
    await page.type '.username', 'kieron'
    await page.type '.password', 'Test123!'
    await page.click 'input[type=submit]'
    await sleep 1000
    text = await page.evaluate () -> document.querySelector('.dashboard h1').innerText
    test.equals text, 'dashboard kieron'
    await page.goto 'http://localhost:23232/bashboard'
    text = await page.evaluate () -> document.querySelector('.bashboard h1').innerText
    test.equals text, 'bashboard kieron'
    await closePage()
    test.done()
  ###