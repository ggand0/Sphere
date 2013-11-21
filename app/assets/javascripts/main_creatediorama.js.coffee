$ ->
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
        #console.log(selectedModelId)
        
        # テクスチャのルートパスを取得
        urlBase = undefined
        if data['url']
          url = data['url'][0]?.replace(/[^/]+$/g,"")
          urlBase = url ? url or '' # URLの最後の"/"以下を取得(404回避)

        controller.reloadModelDatum(JSON.parse(data['modeldata']), urlBase)
      )
    )
  
  
  THREE.ImageUtils.crossOrigin = ""
  
  # ロード開始
  controller = new window.DioramaController()
  controller.create()
  addEventToLink(controller)