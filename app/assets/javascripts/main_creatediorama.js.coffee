$ ->
  DEF_MODELDATA_ID = 0
  DEF_STAGE_ID = 0
  stageJSON = undefined
  stageTexturePath = undefined
  
  # クリックでモデル選択するためのイベントを追加する
  addEventToLink = (controller) ->
    console.log("addEventToLink")
    $test = $("#modelSelection")
    console.log($test)

    $test.children(".item").click((e) ->
      console.log("Begin modeldata request.")

      $.getJSON('/model_data/' + $(@).text() + '.json', (data) ->
        # テクスチャのルートパスを取得する
        # URLの最後の"/"以下を取得(404回避)
        urlBase = undefined
        if data['url']
          url = data['url'][0]?.replace(/[^/]+$/g, "")
          urlBase = url or ''
        controller.reloadModelDatum(data['modeldata'], data['id'], urlBase)
      )
    )
  
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
  getModelDatum = (controller) ->
    deferred = new $.Deferred()
    $.get('get_model_datum', { id: DEF_MODELDATA_ID }
    ).then( (data) ->
      console.log("request of modeldata succeed.")
      console.log(data)
      
      # テクスチャのルートパスを取得
      # URLの最後の"/"以下を取得(404回避)
      urlBase = undefined
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        urlBase = url ? ''
      else
        urlBase = ''
      console.log("modeldata texture path:")
      console.log(urlBase)
      
      controller.reloadModelDatum(data['modelData'], DEF_MODELDATA_ID, urlBase)
      deferred.resolve()
    )
    return deferred.promise()
    
  
  # ロード開始
  THREE.ImageUtils.crossOrigin = ""
  getStageDatum().then(() ->
    # Stageのデータを取得後にコントローラ生成、内部でシーン生成まで先に行う
    controller = new Sphere.DioramaController()
    controller.create(stageJSON, stageTexturePath)
    # その後、別途にデフォルトのモデルデータを読み込む
    getModelDatum(controller)
    # HTML要素にイベント追加
    addEventToLink(controller)
  )
