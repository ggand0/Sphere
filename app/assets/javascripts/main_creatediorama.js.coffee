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
        console.log(JSON.parse(data['modeldata']))
        console.log(data['textures'])
        console.log(data['url'])
        controller.reloadModelDatum(JSON.parse(data['modeldata']), data['url'])
      )
    )
  
  
  THREE.ImageUtils.crossOrigin = ""
  
  # ロード開始
  controller = new window.DioramaController()
  addEventToLink(controller)