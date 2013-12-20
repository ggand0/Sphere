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
    dioramaModel = new Sphere.Diorama()

  # stageのJSONデータをSceneLoaderに投げる
  loadStage = (stageJSON, stageTexturePath) ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    loader.parse(stageJSON, (result) ->
      console.log("StageDatum callback function has been called.")
      dioramaModel.setStageData(result)
      deferred.resolve()
    , stageTexturePath)
    return deferred.promise()

  # showする時にmodelDataを読み込みarrayにセットする
  loadModelData = (modelDataObject) ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    # Mesh単位でロード
    # TODO: ModelData単位にするか考える
    for datum, index in modelDataObject['modelData']
      loader.parse(datum, (result) ->
        console.log("modelData callback function has been called." + loadIndex)
        # sceneで返ってくるのでchildrenを取得
        dioramaModel.addModelDatum(result.scene.children, modelDataObject['ids'][loadIndex])
        loadIndex += 1

        # 最後まで読まれたらresolve
        if loadIndex >= modelDataObject['modelData'].length
          deferred.resolve()
          console.log("loadModelData method has resolved.")
      , modelDataObject['textures'][index])
    return deferred.promise()

  # modelDatumをモデルにセットし直す。create時に使用
  reloadModelDatum: (data, modelId, path) ->
    loader = new THREE.SceneLoader()
    loader.parse(data, (result) ->
      dioramaModel.setModelDatum(result.scene.children, modelId)
      console.log("Modeldata request done.")
    , path)
   
  
  # canvasの描画を開始する
  draw = () ->
    console.log("Begin rendering...")
    dioramaView.animate()
  
  # new.htmlで呼ぶ
  create: (stageJSON, stageTexturePath) ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")

    # まずStageを読む
    loadStage(stageJSON, stageTexturePath).then(() =>
      console.log("Creating view object...")
      
      # 最後にデータをViewに渡してscene生成
      # createなのでモデル追加関連のイベントを追加する
      dioramaView = new Sphere.DioramaView(@, dioramaModel.stageData, true)
      dioramaModel.dioramaView = dioramaView
      
      # 描画開始
      draw()
    )
  
  # show.htmlで呼ぶ
  show: (stageJSON, stageTexturePath, modelDataObject) ->
    # jQueryのdeffered queを用いて
    # RailsからJSONデータを持ってきてロードする
    console.log("Begin loading stage...")

    # まずStageを読む
    loadStage(stageJSON, stageTexturePath, modelDataObject).then(()->
      # 次に個々のモデルを読む
      console.log("Begin loading modelData...")
      loadModelData(modelDataObject).then(() =>
        console.log("Creating view object...")
        
        # 最後にデータをViewに渡してscene生成
        # showなのでモデル操作は禁止する
        dioramaView = new Sphere.DioramaView(@, dioramaModel.stageData, false)
        insertModels(modelDataObject)
        
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
    id = dioramaModel.addModelDatum(model.meshData, model.modelId)
    
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
  insertModels = (modelDataObject) =>
    console.log("Inserting models...")
    console.log("positions:")
    console.log(modelDataObject['transforms'])# rails側から指定するグローバル変数
    
    # ModelにあるmodelDataをViewへ渡す
    for model in dioramaModel.getModelData()
      for mesh in model.meshData
        dioramaView.addModelToScene(mesh)
      
    
namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
namespace "Sphere", (exports) ->
  exports.DioramaController = DioramaController