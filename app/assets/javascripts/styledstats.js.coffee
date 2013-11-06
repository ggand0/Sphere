class StyledStats
  stats = undefined
  
  constructor: () ->
    stats = new Stats()
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.top = '200px'
    stats.domElement.style.left= '500px'
    stats.domElement.style.zIndex = 100
    $('body').append(stats.domElement)
    
  update: () ->
    stats.update()
  
window.StyledStats = window.StyledStats || StyledStats