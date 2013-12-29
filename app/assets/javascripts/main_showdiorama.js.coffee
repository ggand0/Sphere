$ ->
  DEF_MODELDATA_ID = 0
  DEF_STAGE_ID = 0
  stageJSON = undefined
  stageTexturePath = undefined
  modelData = undefined
  
  # サーバーからStageを取得する
  getStageDatum = () ->
    deferred = new $.Deferred()
    $.get('get_stage', { id: DEF_STAGE_ID }
    ).then( (data) ->
      console.log("request of stagedata succeed.")
      
      # Stageデータを取得
      stageJSON = data['stageData']
 
      # テクスチャのルートパスを取得
      # URLの最後の"/"以下を取得(404回避)
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        stageTexturePath = url ? ''
      else
        stageTexturePath = ''
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
      
      # Dioramaデータを取得
      modelData = data

      deferred.resolve()
    )
    return deferred.promise()
  
  
  # ロード開始
  THREE.ImageUtils.crossOrigin = ""
  getStageDatum().then(() ->
    getModelData().then( () ->
      # Stageのデータを取得後にコントローラ生成、内部でシーン生成まで先に行う
      controller = new Sphere.DioramaController()
      controller.show(stageJSON, stageTexturePath, modelData)
    )
  )
  