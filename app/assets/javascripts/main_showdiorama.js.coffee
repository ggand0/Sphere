$ ->
  # サーバーからStageを取得する
  getStageDatum = () ->
    deferred = new $.Deferred()
    $.get('get_stage', { id: DEF_STAGE_ID }
    ).then( (data) ->
      console.log("request of stagedata succeed.")
      console.log(data)
      # モデルデータを取得
      window.modelJSON = data['modelData']
      console.log(window.modelJSON)
 
      # テクスチャのルートパスを取得
      # URLの最後の"/"以下を取得(404回避)
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        window.texturePath = url ? ''
      deferred.resolve()
    )
    return deferred.promise()
    
  # サーバーから(デフォルトで選択される)ModelDataを取得する
  getModelDatum = (controller) ->
    deferred = new $.Deferred()
    $.get('get_model_datum', { id: DEF_MODELDATA_ID }
    ).then( (data) ->
      console.log("request of modeldata succeed.")
      console.log(data)
      # モデルデータを取得
      window.selectedModel = data['modelData']
      window.selectedModelId = DEF_MODELDATA_ID
      
      # テクスチャのルートパスを取得
      urlBase = undefined
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        window.modelTexturePath = url ? '' # URLの最後の"/"以下を取得(404回避)
      console.log(modelTexturePath)
      
      controller.reloadModelDatum(selectedModel, modelTexturePath)
      deferred.resolve()
    )
    return deferred.promise()
  
  
  THREE.ImageUtils.crossOrigin = ""
  
  window.modelDataObj = []
  formatModelData = () ->
    for str in window.modelData
      str = JSON.parse(str)
      modelDataObj.push(str)

  # ロード開始
  formatModelData()
  getStageDatum().then(() ->
    # Stageのデータを取得後にコントローラ生成、内部でシーン生成まで先に行う
    controller = new window.DioramaController()
    controller.show()
  )
  