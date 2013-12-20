$ ->
  DEF_MODELDATA_ID = 103
  DEF_STAGE_ID = 6
  
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
  getModelData = (controller) ->
    deferred = new $.Deferred()
    $.get('get_diorama', { id: $('#id').text() }
    ).then( (data) ->
      console.log("request of modeldata succeed.")
      console.log(data)
      
      # モデルデータを取得
      window.modelDataObj = data['modelData']
      window.textures = data['textures']
      window.modelTransforms = data['transforms']
      window.ids = data['ids']
      
      # テクスチャのルートパスを取得
      # URLの最後の"/"以下を取得(404回避)
      urlBase = undefined
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        window.modelTexturePath = url ? ''

      deferred.resolve()
    )
    return deferred.promise()
  
  
  # ロード開始
  THREE.ImageUtils.crossOrigin = ""
  getStageDatum().then(() ->
    getModelData().then( () ->
      # Stageのデータを取得後にコントローラ生成、内部でシーン生成まで先に行う
      controller = new window.DioramaController()
      controller.show()
    )
  )
  