# 通信やDiorama操作周りを(中で)担当する
class DioramaController
  dioramaModel = undefined  # データを格納するだけの機能を持つモデル
  dioramaView = undefined   # Scene生成やイベント周りを担当するビューオブジェクト
  loaded = false

  # ここではグローバルで与えられたJSONデータをロードし、
  # それらを用いてModelとView(Scene)生成するまでを行う
  constructor: () ->
    dioramaModel = new Diorama()
    
  # new.htmlで呼ぶ
  create: () ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")
    self = @
    # まずStageを読む
    loadStage().then(()->
      console.log("Creating view object...")
      # 最後にデータをViewに渡してscene生成
      # createなのでモデル追加関連のイベントを追加する
      dioramaView = new DioramaView(self, dioramaModel.stageData, true)
      dioramaModel.dioramaView = dioramaView
      # 描画開始
      draw()
    )
  
  # stageのJSONデータをSceneLoaderに投げる
  loadStage = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    console.log(window.modelJSON)
    loader.parse(window.modelJSON, (result) ->
      console.log("StageDatum callback function has been called.")
      dioramaModel.setStageData(result)
      deferred.resolve()
    , texturePath)
    return deferred.promise()

  # modelDatumのJSONデータをSceneLoaderに投げる
  loadModelDatum = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    loader.parse(window.selectedModel, (result) ->
      console.log("modelDatum callback function has been called.")
      # sceneで返ってくるのでchildrenを取得
      #dioramaModel.setModelDatum(result.scene.children[0])
      dioramaModel.setModelDatum(result.scene.children[0], selectedModelId)
      #dioramaModel.setModelDatum(, result.scene.children[0], 0)
      console.log(dioramaModel.getModelDatum())
      deferred.resolve()
    , modelTexturePath)
    return deferred.promise()
    
  loadIndex = 0
  # showする時にmodelDataを読み込みarrayにセットする
  loadModelData = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    console.log("length=" + modelDataObj.length)
    # railsで与えられたarray分だけロード[要改善]
    for datum, index in modelDataObj
      loader.parse(datum, (result) ->
        console.log("modelData callback function has been called. " + loadIndex)
        loadIndex += 1# メンバ変数のカウンタを使うことにする
        
        # sceneで返ってくるのでchildrenを取得
        dioramaModel.addModelDatum(result.scene.children[0], 0)# id要修正
        console.log(dioramaModel.getModelData())
        
        # 最後まで読まれたらresolve
        #if index >= modelDataObj.length-1# ここでindex参照して条件に使っても意味NEEE
        if loadIndex >= modelDataObj.length
          deferred.resolve()
          console.log("loadModelData method has resolved.")
      , textures[index])
    return deferred.promise()

  # modelDatumをモデルにセットし直す
  reloadModelDatum : (data, path) ->
    loader = new THREE.SceneLoader()
    loader.parse(data, (result) ->
      console.log("modelDatum callback function has been called.")
      if result.scene.children.length == 1
        dioramaModel.setModelDatum(result.scene.children, undefined)
      else
        dioramaModel.setModelDatum(result.scene.children, result.objects)
        console.log("current model:")
        console.log(result)
        console.log(dioramaModel.getModelDatum())
        console.log(path)
    , path)
   
  
  # canvasの描画を開始する
  draw = () ->
    console.log("Begin rendering...")
    dioramaView.animate()
    
  # 以前のコードを置いてるだけ[未実装]
  show: () ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")
    #console.log(@)
    self = @
    # まずStageを読む
    loadStage().then(()->
      # 次に個々のモデルを読む（とりあえず今は１つだけ）
      console.log("Begin loading modelDatum...")
      loadModelData().then(()->
        console.log("Creating view object...")
        # 最後にデータをViewに渡してscene生成
        # showなのでモデル操作は禁止
        dioramaView = new DioramaView(self, dioramaModel.stageData, false)
        
        console.log("Inserting models...")
        insertModels()
        
        # 描画開始
        draw()
      )
    )

  
  # 内包表記用の関数
  # タプルを返すように変更
  stringify = (value) ->
    obj = new Object()
    obj.id = value.id
    obj.pos = value.transform.toArray()
    console.log("obj:")
    console.log(obj)
    return obj
    
  
  # 配置されたモデルの位置を取得しarrayに格納して返す
  getModelTransforms = () ->
    array = (stringify(value) for value in dioramaModel.getModelData())
    return array
    
  # モデルの位置情報とIDを取得してarrayに格納しreturnする
  getModelData = () ->
    array = []


  handleKeyEvents: (event) =>
    console.log("keyCode = " + event.keyCode)
    if event.keyCode is 100           # Dキー
      deleteModel()
    else if event.keyCode is 115      # Sキー
      console.log(getSelectedModels())
    else if event.keyCode is 99      # Cキー
      console.log(dioramaModel.getModelData())
    else if event.keyCode is 103      # Gキー
      console.log(dioramaView.getScene())
    else if event.keyCode is 105      # Iキー
      
    else
      addModel(event)

  getSelectedModels = () ->
    array = (obj for obj in dioramaView.getAllSceneObjects() when obj.userData['selected'] is true)
    return array

  # モデルをSceneとmodelDataから削除する
  deleteModel = () =>
    console.log("Deleting models...")
    # 選択されているモデルを削除
    # 選択されていないモデルだけ残してセットし直す
    array = getSelectedModels()
    dioramaView.removeModels(array)
        
    # modelData側でも同様に消す、もう少し効率良くしたい
    #dioramaModel.setModelData(dioramaView.getSceneObjects())
    dioramaModel.removeModels(array)

  # モデルをジオラマのシーンに追加する
  addModel = () =>
    # ToDo:dioramaViewがdioramaModelを参照してsceneを更新するようにする
    # 取得したモデルデータをViewが持っているsceneに追加する(Viewのメソッドを呼ぶ形にしたほうが良いかも)
    meshes = (mesh.clone() for mesh in dioramaModel.getModelDatum(@).meshData)
    console.log(meshes)
    
    for mesh in meshes
      # Sceneに追加
      mesh.castShadow = true
      dioramaView.addModelToScene(mesh)
      # Dioramaに追加
      #newModel = new ModelData(selectedModelMesh.data, selectedModelId, mesh.position)
      m = []
      m.push(mesh.data)
      newModel = new ModelData(m, selectedModelId, mesh.position)
      dioramaModel.addModelDatum(newModel)
      console.log(newModel)

    # Dioramaにも追加
    ###selectedModelMesh = dioramaModel.getModelDatum()
    newModel = new ModelData(selectedModelMesh.data, selectedModelId, newMesh.position)
    dioramaModel.addModelDatum(newModel)
    console.log(newModel)###
  
  
  # 既存のジオラマをshowする時に、modelTransformsで与えられた位置にモデルを配置する
  insertModels =  () =>
    console.log("positions:")
    console.log(modelTransforms)# rails側から指定するグローバル変数
    
    # Convert JSON to array
    positions = []
    $.each(modelTransforms, (i, obj) ->
      positions.push(JSON.parse(obj))
    )
    console.log(positions)

    data = dioramaModel.getModelData()
    # modelTransformsで与えられる位置に配置する 
    for value, index in positions
      newMesh = new THREE.Mesh( data[index].geometry,
        data[index].material)
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      
      pos = new THREE.Vector3().fromArray(value)
      console.log(pos)
      
      newMesh.position = pos
      dioramaView.addModelToScene(newMesh)
  

  # ジオラマのモデルの位置データをViewのフォームに入力する
  insertTransforms: (event) ->
    console.log("Inserting transforms to form...")
    positions = getModelTransforms()
    
    console.log(positions)
    console.log(JSON.stringify(positions))
    
    $(document).ready () ->
      $("#transforms_field").val(JSON.stringify(positions))
      

  # Railsのcontroller内のactionにデータを送るテスト
  send= (event) ->
    console.log(scene.objects)
    console.log(scene.scene.children)
    console.log("begin ajax request.")
    ### 未移植
    $.ajax({
      url: 'ready',
      type: 'POST',
      data: {
        code: getModelTransforms()
        #code: "data from javascript."
      },
      success: (data, event, status, xhr) ->
        console.log("request succeed.")
      ,error: (event, data, status, xhr) ->
        console.log("request failed.")
    })
    ###
    
window.DioramaController = window.DioramaController or DioramaController