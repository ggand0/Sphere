# 通信やDiorama操作周りを(中で)担当する
class DioramaController
  ADD_MODEL_KEY = 100
  DELETE_MODEL_KEY = 100
  GET_SELECTED_KEY = 115
  GET_MODELDATA_KEY = 99
  GET_SCENE_KEY = 103
  
  dioramaModel = undefined  # データを格納するだけの機能を持つモデル
  dioramaView = undefined   # Scene生成やイベント周りを担当するビューオブジェクト
  loaded = false
  loadIndex = 0
  
  

  # ここではグローバルで与えられたJSONデータをロードし、
  # それらを用いてModelとView(Scene)生成するまでを行う
  constructor: () ->
    dioramaModel = new Diorama()

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

  # showする時にmodelDataを読み込みarrayにセットする
  loadModelData = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    console.log("length=" + modelDataObj.length)
    
    # Mesh単位でロード
    # TODO: ModelData単位にするか考える
    for datum, index in modelDataObj
      loader.parse(datum, (result) ->
        console.log("modelData callback function has been called." + loadIndex)
        # sceneで返ってくるのでchildrenを取得
        dioramaModel.addModelDatum(result.scene.children, ids[loadIndex])
        loadIndex += 1

        # 最後まで読まれたらresolve
        if loadIndex >= modelDataObj.length
          deferred.resolve()
          console.log("loadModelData method has resolved.")
      , textures[index])
    return deferred.promise()

  # modelDatumをモデルにセットし直す。create時に使用
  reloadModelDatum: (data, path) ->
    loader = new THREE.SceneLoader()
    loader.parse(data, (result) ->
      console.log("modelDatum callback function has been called.")
      if result.scene.children.length == 1
        dioramaModel.setModelDatum(result.scene.children, selectedModelId)
      else
        dioramaModel.setModelDatum(result.scene.children, selectedModelId)
        console.log("current model:")
        console.log(result)
        console.log(dioramaModel.getModelDatum())
        console.log(path)
    , path)
   
  
  # canvasの描画を開始する
  draw = () ->
    console.log("Begin rendering...")
    dioramaView.animate()
  
  # new.htmlで呼ぶ
  create: () ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")

    # まずStageを読む
    loadStage().then(() =>
      console.log("Creating view object...")
      
      # 最後にデータをViewに渡してscene生成
      # createなのでモデル追加関連のイベントを追加する
      dioramaView = new DioramaView(@, dioramaModel.stageData, true)
      dioramaModel.dioramaView = dioramaView
      
      # 描画開始
      draw()
    )
  
  # show.htmlで呼ぶ
  show: () ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")

    # まずStageを読む
    loadStage().then(()->
      # 次に個々のモデルを読む
      console.log("Begin loading modelData...")
      loadModelData().then(() =>
        console.log("Creating view object...")
        
        # 最後にデータをViewに渡してscene生成
        # showなのでモデル操作は禁止する
        dioramaView = new DioramaView(@, dioramaModel.stageData, false)
        insertModels()
        
        # 描画開始
        draw()
      )
    )
    
  handleKeyEvents: (event) =>
    console.log("keyCode = " + event.keyCode)
    if event.keyCode is DELETE_MODEL_KEY            # Dキー
      deleteModel()
    else if event.keyCode is GET_SELECTED_KEY       # Sキー
      console.log(getSelectedModels())
    else if event.keyCode is GET_MODELDATA_KEY      # Cキー
      console.log('dioramaModel.modelData:')
      console.log(dioramaModel.getModelData())
    else if event.keyCode is GET_SCENE_KEY          # Gキー
      console.log(dioramaView.getScene())
    else
      addModel()
  
  
  # MeshをDioramaに追加する
  addModel = (model=dioramaModel.getModelDatum()) =>
    # TODO: ModelData.clone()を実装する
    # 新規にModelDataを生成してModelに追加
    id = dioramaModel.addModelDatum(model.meshData, selectedModelId)
    
    # 続いてViewに追加
    m = getModel(id)
    for mesh in m.meshData
      dioramaView.addModelToScene(mesh.clone())

  getModel = (id) ->
    return (model for model in dioramaModel.modelData when model.id is id)[0]
  
  # ViewのMeshの選択状態の変更をModelに反映する
  selectModel: (id) ->
    target = (data for data in dioramaModel.modelData when data.id is id)
    # idはModelData個別
    for t in target
      t.meshData[0].userData['selected'] = !t.meshData[0].userData['selected']
    
  # 選択されたMeshをSceneとmodelDataから削除する
  deleteModel = () =>
    console.log("Deleting models...")
    dioramaModel.deleteModels() # modelData(Model)から削除
    dioramaView.deleteModels()  # Scene(View)から削除
  
  # 内包表記用の関数
  # タプルを返すように変更
  stringify = (value) ->
    obj = new Object()
    obj.id = value.modelId
    #obj.pos = value.transform.toArray()
    obj.pos = value.meshData[0].position.toArray()
    console.log("obj:")
    console.log(obj)
    return obj
    
  # 配置されたモデルの位置を取得しarrayに格納して返す
  getModelTransforms = () ->
    array = (stringify(value) for key, value of dioramaModel.getModelData())
    return array
    
  # Viewで動かしたモデルの位置をModelに反映する。
  # 個別に毎回保存しないでまとめて反映してもいいかも
  updateModelTransforms = (id, subId, newPosition) ->
    dioramaModel.modelData[id].meshData[subId].transform = newPosition

  getSelectedModels = () ->
    array = (obj for obj in dioramaView.getAllSceneObjects() when obj.userData['selected'] is true)
    return array

  # ジオラマのモデルの位置データをViewのフォームに入力する
  insertTransforms: (event) ->
    console.log("Inserting transforms to form...")
    positions = getModelTransforms()
    console.log(positions)
    console.log(JSON.stringify(positions))
    $(document).ready () ->
      $("#transforms_field").val(JSON.stringify(positions))
      
  # 既存のジオラマをshowする時に、modelTransformsで与えられた位置にモデルを配置する
  insertModels = () =>
    console.log("Inserting models...")
    console.log("positions:")
    console.log(modelTransforms)# rails側から指定するグローバル変数
    
    # ModelにあるmodelDataをViewへ渡す
    for model in dioramaModel.getModelData()
      for mesh in model.meshData
        dioramaView.addModelToScene(mesh)
      
    
window.DioramaController = window.DioramaController or DioramaController