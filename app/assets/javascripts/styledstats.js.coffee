class StyledStats
  stats = undefined
  
  constructor: (top, left) ->
    stats = new Stats()
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.top = top
    stats.domElement.style.left= left# E.g. '500px'
    stats.domElement.style.zIndex = 100
    $('body').append(stats.domElement)
    
  update: () ->
    stats.update()


namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
namespace "Sphere", (exports) ->
  exports.StyledStats = StyledStats