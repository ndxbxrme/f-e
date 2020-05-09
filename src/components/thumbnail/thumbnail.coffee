config = require '../../config.json'
module.exports = (image, size) ->
  return null if not image
  size = size or 100
  config.cloudinary.imageUrl + '/w_' + size + ',h_' + size + ',c_lfill/' + image