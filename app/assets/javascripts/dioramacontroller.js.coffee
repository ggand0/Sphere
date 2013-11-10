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
    #console.log(@)
    self = @
    # まずStageを読む
    loadStage.call(this).then(()->
      # 次に個々のモデルを読む（とりあえず今は１つだけ）
      console.log("Begin loading modelDatum...")
      loadModelDatum.call(this).then(()->
        console.log("Creating view object...")
        
        # 最後にデータをViewに渡してscene生成
        # createなのでモデル追加関連のイベントを追加する
        dioramaView = new DioramaView(self, dioramaModel.stageData, true)
        
        # 描画開始
        draw.call(this)
      )
    )
    
  # stageのJSONデータをSceneLoaderに投げる
  loadStage = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    loader.parse(modelJSON, (result) ->
      console.log("StageDatum callback function has been called.")
      dioramaModel.setStageData(result)
      deferred.resolve()
    , texturePath)
    return deferred.promise()

  # modelDatumのJSONデータをSceneLoaderに投げる
  loadModelDatum = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    loader.parse(selectedModel, (result) ->
        console.log("modelDatum callback function has been called.")
        
        # sceneで返ってくるのでchildrenを取得
        #dioramaModel.setModelDatum(result.scene.children[0])
        dioramaModel.setModelDatum.call(this, result.scene.children[0], selectedModelId)
        #dioramaModel.setModelDatum.call(this, result.scene.children[0], 0)
        console.log(dioramaModel.getModelDatum())
        deferred.resolve()
    , modelTexturePath)
    return deferred.promise()
    
  loadIndex = 0
  # showする時にmodelDataを読み込みarrayにセットする
  loadModelData = () ->
    deferred = new $.Deferred()
    loader = new THREE.SceneLoader()
    
    console.log("length="+modelDataObj.length)
    # railsで与えられたarray分だけロード[要改善]
    for datum, index in modelDataObj
      loader.parse(datum, (result) ->
          console.log("modelData callback function has been called. " + loadIndex)
          loadIndex += 1# メンバ変数のカウンタを使うことにする
          
          # sceneで返ってくるのでchildrenを取得
          #dioramaModel.setModelData.call(this, result.scene.children[0], selectedModelId)# idも要修正
          dioramaModel.addModelDatum.call(this, result.scene.children[0], 0)# id要修正
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
        dioramaModel.setModelDatum.call(this, result.scene.children[0])
        #deferred.resolve()
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
    loadStage.call(this).then(()->
      # 次に個々のモデルを読む（とりあえず今は１つだけ）
      console.log("Begin loading modelDatum...")
      loadModelData.call(this).then(()->
        console.log("Creating view object...")
        # 最後にデータをViewに渡してscene生成
        # showなのでモデル操作は禁止
        dioramaView = new DioramaView(self, dioramaModel.stageData, false)
        
        console.log("Inserting models...")
        insertModels.call(this)
        
        # 描画開始
        draw.call(this)
      )
    )

  
  # 内包表記用の関数
  # タプルを返すように変更
  stringify = (value) ->
    #JSON.stringify(value.position.toArray())
    
    #return JSON.stringify([value.id, JSON.stringify(value.transform.toArray())])
    #str = '{ "id":value.id, "pos":JSON.stringify(value.transform.toArray()) }'
    #
    obj = new Object()
    obj.id = value.id
    obj.pos = value.transform.toArray()
    #str = JSON.stringify(obj)
    console.log("obj:")
    console.log(obj)
    #console.log(str)
    return obj
    ###
    ar = []
    ar['id'] = value.id
    ar['pos'] = value.transform.toArray()
    console.log("ar:")
    console.log(ar)
    console.log(JSON.stringify(ar))
    return JSON.stringify(ar)
    ###
  
  # 配置されたモデルの位置を取得しarrayに格納して返す
  getModelTransforms = () ->
    #array = (stringify(value) for value in diorama.scene.scene.children when value instanceof THREE.Mesh)
    #array = (stringify(value) for value in dioramaView.getSceneObjects() when value instanceof THREE.Mesh)
    array = (stringify(value) for value in dioramaModel.getModelData())
    return array
    
  # モデルの位置情報とIDを取得してarrayに格納しreturnする
  getModelData = () ->
    array = []


  # モデルをジオラマのシーンに追加する
  addModel: (event) =>
    # モデルがロードされていない場合return
    #return unless selectedModelLoaded
    
    # モデルデータをModelから取得する
    selectedModelMesh = dioramaModel.getModelDatum().data
    
    # 取得したデータからMesh生成
    newMesh = new THREE.Mesh( selectedModelMesh.geometry,
      #new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ))
      #new THREE.MeshLambertMaterial())
      selectedModelMesh.material)
    newMesh.scale = new THREE.Vector3(10, 10, 10)
    newMesh.position = new THREE.Vector3(Math.random() * 100, Math.random() * 100, Math.random() * 100)

    # ToDo:dioramaViewがdioramaModelを参照してsceneを更新するようにする
    # 取得したモデルデータをViewが持っているsceneに追加する(Viewのメソッドを呼ぶ形にしたほうが良いかも)
    dioramaView.addModelToScene(newMesh)
    # Dioramaにも追加
    newModel = new ModelData(selectedModelMesh, selectedModelId, newMesh.position)
    dioramaModel.addModelDatum(newModel)
    console.log(newModel)
  
  # 既存のジオラマをshowする時に、modelTransformsで与えられた位置にモデルを配置する
  #insertModel: () =>
  insertModels =  () =>
    console.log("positions:")
    console.log(modelTransforms)# rails側から指定するグローバル変数
    
    # Convert JSON to array
    positions = []
    $.each(modelTransforms, (i, obj) ->
      #console.log(obj)
      positions.push(JSON.parse(obj))
    )
    console.log(positions)

    data = dioramaModel.getModelData()
    # modelTransformsで与えられる位置に配置する 
    for value, index in positions
      #newMesh = new THREE.Mesh( selectedModelMesh.geometry,
      #  selectedModelMesh.material)
      newMesh = new THREE.Mesh( data[index].geometry,
        data[index].material)
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      
      #pos = new THREE.Vector3().fromArray(positions[i])
      pos = new THREE.Vector3().fromArray(value)
      console.log(pos)
      
      newMesh.position = pos
      #scene.scene.add(newMesh)
      #modelObjects.push(newMesh)  # 判定用に使用する、モデルのみを入れる配列
      dioramaView.addModelToScene(newMesh)
    #console.log(scene)
  

  # ジオラマのモデルの位置データをViewのフォームに入力する
  insertTransforms: (event) ->
    console.log("Inserting transforms to form...")
    positions = getModelTransforms.call(this)
    
    console.log(positions)
    console.log(JSON.stringify(positions))
    
    $(document).ready () ->
      $("#transforms_field").val(JSON.stringify(positions))
      #$("#transforms_field").val(positions)
      

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