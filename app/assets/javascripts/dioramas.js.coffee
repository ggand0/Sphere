# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# JSONDataのみを格納するオブジェクト
class ModelData
  data: undefined       # JSONで記述されたモデルデータ
  id: undefined         # DB上のID
  transform: undefined  # 位置ベクトル
  
  constructor: (data, id, transform) ->
    @data = data
    @id = id
    @transform = transform

# ジオラマが持つJSONDataの集合
class Diorama
  # プロパティでもいいかも
  # 今のところModelDataではなくJSONStringを直接持つ仕様
  stageData: undefined
  modelDatum = undefined  # 当面使う単一のモデルデータ用の変数
  modelData = []          # ModelDataのリスト、将来使う

  constructor: () ->
    
  ###constructor: (stage) ->
    this.stageData = stage###
  ###constructor: (stage, data) ->
    this.stageData = stage
    this.modelDatum = data###

  setStageData: (data) ->
    console.log("Setting stageData...")
    @stageData = data
    #console.log(data)
    #console.log(@stageData)
  setModelDatum: (data, id) ->
    #modelDatum = data
    modelDatum = new window.ModelData(data, id)
    
  addModelDatum: (model) ->
    modelData.push(model)
  
  # getter
  getStageData: () ->
    return stageData
  getModelData: () ->
    return modelData
  getModelDatum: () ->
    return modelDatum


window.ModelData = window.ModelData or ModelData
window.Diorama = window.Diorama or Diorama
