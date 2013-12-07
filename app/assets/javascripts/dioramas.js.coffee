# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# JSONDataなど１つのモデルに関するデータを格納するクラス。構造体的に使う
class ModelData
  data: undefined         # parseされたTHREE.Mesh(オリジナル)の配列
  id: undefined           # DB上のID
  transform: undefined    # 位置ベクトル
  meshData: undefined     # シーンとやりとりするのに使う（リアルタイムな位置情報を持ってる）Three.Meshの配列
  
  constructor: (data, id, transform) ->
    @data = data
    @id = id
    @transform = transform
    generateMesh.call(@)
  
  # 取得したデータからMesh生成
  generateMesh = () ->
    @meshData = []
    for d, index in @data
      newMesh = new THREE.Mesh( d.geometry, d.material)
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      newMesh.position = d.position#@transforms
      newMesh.userData = { selected: false, subId: index }
      @meshData.push(newMesh)


# ジオラマが持つJSONDataの集合
class Diorama
  # プロパティでもいいかも
  stageData: undefined    # Stageを格納する変数
  modelDatum = undefined  # 現在追加しようとしている（単一の）モデル
  modelData = []          # 現在ジオラマ上に存在しているModelDataのArray

  constructor: () ->

  addModelDatum: (model, id) ->
    #modelData.push(model)
    modelData[id] = model
  removeModels: (targets) ->
    console.log("Removing targets from modelData...")
    dels = (obj for obj in modelData when obj.meshData is t for t in targets)
    indices = (modelData.indexOf(d[0]) for d in dels)
    
    for i in indices
      modelData.splice(i[0], 1)
      
    console.log("Deletion is completed!")
    console.log(modelData)

    
  　# setter
  setStageData: (data) ->
    console.log("Setting stageData...")
    @stageData = data
  setModelDatum: (data, id) ->
    modelDatum = new window.ModelData(data, id, new THREE.Vector3(0,0,0))
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
