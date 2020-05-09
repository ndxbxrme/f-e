pad = (n) ->
  ('00' + n).substr n.toString().length
module.exports = 
  date: (date) ->
    d = new Date(date)
    pad(d.getDate()) + '/' + pad(d.getMonth() + 1) + '/' + d.getFullYear()
  time: (date) ->
    d = new Date(date)
    pad(d.getHours()) + ':' + pad(d.getMinutes())
  dateTime: (date) ->
    @date(date) + ', ' + @time(date)