module.exports =
  boxTemplate: (item) ->
    require('./box-template.pug') item: item
  percent: (item) ->
    item.currentTime / (item.schedule * 60 * 60 * 1000) * 100
  state: (item) ->
    schedulePercent = item.currentTime / (item.schedule * 60 * 60 * 1000) * 100
    return 'danger' if schedulePercent > 90
    return 'warning' if schedulePercent > 80
    return 'ok' if schedulePercent > 50
    return 'good'