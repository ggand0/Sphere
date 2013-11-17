$ ->
  # クリックでモデル選択するためのイベントを追加する
  addEventToLink = (controller) ->
    console.log("addEventToLink")
    $test = $("#modelSelection")
    console.log($test)

    $test.children(".item").click((e) ->
      #console.log("event fired.")
      #console.log(e)
      #console.log(e.target)
      console.log(e.target.innerText)
      console.log("Begin ajax request.")

      $.getJSON('/model_data/' + e.target.innerText + '.json', (data) ->
        #console.log(JSON.parse(data['modeldata']))
        #console.log(data['textures'])
        console.log("url:")
        console.log(data['url'])
        
        console.log("id:")
        console.log(data['id'])
        window.selectedModelId = data['id']
        #console.log(selectedModelId)
        
        # テクスチャのルートパスを取得
        urlBase = undefined
        if data['url']
          url = data['url'][0]
          urlBase = url.replace(url.substr(url.lastIndexOf('/') + 1), '')

        #controller.reloadModelDatum(JSON.parse(data['modeldata']), if data['url'] then data['url'] else "")
        controller.reloadModelDatum(JSON.parse(data['modeldata']), if urlBase then urlBase else "")
      )
    )
  
  
  THREE.ImageUtils.crossOrigin = ""
  
  # ロード開始
  controller = new window.DioramaController()
  controller.create()
  addEventToLink(controller)