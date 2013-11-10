$ ->
  THREE.ImageUtils.crossOrigin = ""
  
  window.modelDataObj = []
  formatModelData = () ->
    for str in window.modelData
      str = JSON.parse(str)
      modelDataObj.push(str)

  # ロード開始
  formatModelData()
  #console.log(modelData)
  
  console.log("modelData:")
  console.log(window.modelData)
  console.log(window.modelDataObj)
  console.log("textures url:")
  console.log(window.textures)
  #console.log(JSON.parse(modelData[0]))
  #console.log(selectedModel)
  
  controller = new window.DioramaController()
  controller.show()
  