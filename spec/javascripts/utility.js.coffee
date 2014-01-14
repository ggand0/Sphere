class Utility
  constructor: () ->
    
  includeCamera: (objects) ->
    for obj in objects
      return true if (obj instanceof THREE.PerspectiveCamera)
      #return true if (obj instanceof THREE.Object3D)
    false
  
  includeLight: (objects) ->
    for obj in objects
      return true if obj instanceof THREE.Light
    false
  
  isObjectsRotated: (objects) ->
    for i in objects
      return false if i.rotation.x is not -90 * Math.PI / 180
    true

namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
namespace "Sphere", (exports) ->
  exports.Utility = Utility