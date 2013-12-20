# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# JSONDataなど１つのモデルに関するデータを格納するクラス。構造体的に使う
class ModelData
  DEF_SCALE = new THREE.Vector3(10,10,10)
  data: undefined         # parseされたTHREE.Mesh(オリジナル)の配列
  id: undefined           # 識別ID(Diorama.modelDataへ追加時に設定される)
  modelId: undefined      # ModelDataのDB上のID
  transform: undefined    # 位置ベクトル
  meshData: undefined     # シーンとやりとりするのに使う（リアルタイムな位置情報を持ってる）Three.Meshの配列
  
  constructor: (data, id, modelId, transform) ->
    @data = data
    @id = id
    @modelId = modelId
    @transform = transform
    generateMesh.call(@)
  
  # 取得したMeshを調整したMeshを生成する
  generateMesh = () ->
    @meshData = []
    for d, index in @data
      newMesh = new THREE.Mesh( d.geometry, d.material)
      newMesh.scale = DEF_SCALE
      newMesh.position = d.position
      newMesh.userData = { selected: false, id: @id, subId: index }
      newMesh.castShadow = true
      @meshData.push(newMesh)


# Stageと、ユーザーに追加されたModelDataのMeshをまとめるジオラマクラス。
class Diorama
  # プロパティでもいいかも
  stageData: undefined      # Stageを格納する変数
  modelDatum = undefined    # 現在追加しようとしている（単一の）モデル
  modelData: []             # 現在ジオラマ上に存在しているModelDataのArray
  id = -1                   # 追加されたModelDataのID

  constructor: () ->

  # modelDataにmodelを追加する
  addModelDatum: (data, modelId) ->
    #@modelData['id'+id.toString()] = model
    id++
    @modelData.push( new ModelData(data, id, modelId, new THREE.Vector3(0,0,0)) )
    return id
  
  getIndices = (meshData, mesh) ->
    return { dataId: @modelData.indexOf(meshData), meshId: meshData.indexOf(mesh) }
  
  # TODO: Mesh単位の削除に対応する
  selected = (data) ->
    for mesh in data.meshData
      if mesh.userData['selected']
        return true
    return false
  
  # @modelDataから対象を削除する
  # targets:削除対象ModelDataのリスト
  # TODO: Mesh単位の削除に対応する
  # TODO: Controllerに処理を移す
  deleteModels: () ->
    console.log("Removing targets from @modelData...")
    #dels = (getIndices(meshData, mesh) for mesh in data.meshData for data in @modelData when mesh.userData.selected)
    
    # 選択されていないdataだけ残したmodelDataを新たに設定する
    newModelData = @modelData.filter(
      (data) ->
        return !selected(data)
    )
    @setModelData(newModelData)

  
  　# Setter
  setStageData: (data) ->
    console.log("Setting stageData...")
    @stageData = data
  setModelDatum: (data, modelId) ->
    modelDatum = new window.ModelData(data, 0, modelId, new THREE.Vector3(0,0,0))
  setModelData: (data) ->
    @modelData = data
  
  # Getter
  getStageData: () ->
    return stageData
  getModelData: () ->
    return @modelData
  getModelDatum: () ->
    return modelDatum


window.ModelData = window.ModelData or ModelData
window.Diorama = window.Diorama or Diorama
