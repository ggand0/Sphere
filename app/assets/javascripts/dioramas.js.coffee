# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# JSONDataなど１つのモデルに関するデータを格納するクラス。構造体的に使う
class ModelData
  data: undefined       # JSONで記述されたモデルデータ
  id: undefined         # DB上のID
  transform: undefined  # 位置ベクトル
  # Object3D.userData(つまｔりdata.userData)を使うことにする
  #selected: false       # ユーザによって選択されているかどうか
  meshData: undefined    # Three.Mesh
  
  
  constructor: (data, id, transform) ->
    @data = data
    @id = id
    @transform = transform
    generateMesh.call(this)
    
  generateMesh = () ->
    # 取得したデータからMesh生成
    newMesh = new THREE.Mesh( @data.geometry,
      @data.material)
    newMesh.scale = new THREE.Vector3(10, 10, 10)
    newMesh.position = new THREE.Vector3(Math.random() * 100, Math.random() * 100, Math.random() * 100)
    newMesh.userData = { selected: false }
    @meshData = newMesh

# ジオラマが持つJSONDataの集合
class Diorama
  # プロパティでもいいかも
  stageData: undefined    # Stageを格納する変数
  modelDatum = undefined  # 単一のモデルデータ用の変数
  modelData = []          # ModelDataのリスト

  constructor: () ->

  
  addModelDatum: (model) ->
    modelData.push(model)
  #selectModelDatum: (selectedModel) ->
  removeModels: (targets) ->
    console.log("Removing targets from modelData...")
    #dels = (obj for obj in modelData.data when obj is t for t in targets)
    dels = (obj for obj in modelData when obj.meshData is t for t in targets)
    console.log(dels)
    indices = (modelData.indexOf(d[0]) for d in dels)
    console.log(indices)
    
    console.log("Current modelData:")
    console.log(modelData)
    for i in indices
      modelData.splice(i[0], 1)
      
    console.log("Deletion is completed!")
    console.log(modelData)
    #for d in dels
    # modelData.remove(d[0])
    
    
  　# setter
  setStageData: (data) ->
    console.log("Setting stageData...")
    @stageData = data
    #console.log(data)
    #console.log(@stageData)
  setModelDatum: (data, id) ->
    #modelDatum = data
    modelDatum = new window.ModelData(data, id)
  setModelData: (data) ->
    modelData = data
  
  # getter
  getStageData: () ->
    return stageData
  getModelData: () ->
    return modelData
  getModelDatum: () ->
    return modelDatum


window.ModelData = window.ModelData or ModelData
window.Diorama = window.Diorama or Diorama
