$ ->
  DEF_MODELDATA_ID = 103
  DEF_STAGE_ID = 6
  
  # クリックでモデル選択するためのイベントを追加する
  addEventToLink = (controller) ->
    console.log("addEventToLink")
    $test = $("#modelSelection")
    console.log($test)

    $test.children(".item").click((e) ->
      console.log(e.target.innerText)
      console.log("Begin ajax request.")

      $.getJSON('/model_data/' + e.target.innerText + '.json', (data) ->
        console.log("url:")
        console.log(data['url'])
        console.log("id:")
        console.log(data['id'])
        window.selectedModelId = data['id']
        
        # テクスチャのルートパスを取得する
        # URLの最後の"/"以下を取得(404回避)
        urlBase = undefined
        if data['url']
          url = data['url'][0]?.replace(/[^/]+$/g, "")
          urlBase = url or '' 
        console.log(data['modeldata'])
        controller.reloadModelDatum(data['modeldata'], urlBase)
      )
    )
  
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
    
  
  # ロード開始
  THREE.ImageUtils.crossOrigin = ""
  getStageDatum().then(() ->
    # Stageのデータを取得後にコントローラ生成、内部でシーン生成まで先に行う
    controller = new window.DioramaController()
    controller.create()
    # その後、別途にデフォルトのモデルデータを読み込む
    getModelDatum(controller)
    # HTML要素にイベント追加
    addEventToLink(controller)
  )
