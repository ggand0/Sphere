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
  
window.StyledStats = window.StyledStats || StyledStats