$ ->
  THREE.ImageUtils.crossOrigin = ""
  
  window.modelDataObj = []
  formatModelData = () ->
    for str in window.modelData
      str = JSON.parse(str)
      modelDataObj.push(str)

  # ロード開始
  formatModelData()
  controller = new window.DioramaController()
  controller.show()
  