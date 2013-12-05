# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# JSONDataなど１つのモデルに関するデータを格納するクラス。構造体的に使う
class ModelData
  data: undefined         # JSONで記述されたモデルデータ　の配列
  id: undefined           # DB上のID
  transform: undefined    # 位置ベクトル
  meshData: undefined     # Three.Mesh　の配列
  dioramaView: undefined
  
  constructor: (data, id, transform) ->
    @data = data
    @id = id
    @transform = transform
    generateMesh.call(@)
  
  # 取得したデータからMesh生成
  generateMesh = () ->
    @meshData = []
    for d in @data
      #toonMaterial = new THREE.ShaderMaterial(THREE.Toon['toon0'])
      ###toonMaterials = []
      console.log(d)
      if d instanceof THREE.Mesh
        for mat in d.material.materials
          toonMaterial = new THREE.ShaderMaterial({
            fragmentShader: document.getElementById('fs').innerHTML,
            vertexShader  : document.getElementById('vs').innerHTML,
            attributes: {
              color: {
                type: 'v4',
                value: new THREE.Vector4(0, 0, 0, 0)
              }
            },
            uniforms: {
              edgeColor: {
                type: 'v4',
                value: new THREE.Vector4(0, 0, 0, 0)
              },
              edge: {
                type: 'i',
                value: true
              },
              lightDirection: {
                type: 'v3',
                #value: dioramaView.scene.lights[0].position
                value: new THREE.Vector3(0, 100, 100)
              },
              texture: {
                type: 't',
                #value: THREE.ImageUtils.loadTexture('textures/toon.png')
                value: mat.map
              },
              
            }
          })
          toonMaterials.push(toonMaterial)
      ###
      #newMesh = new THREE.Mesh( d.geometry, new THREE.MeshFaceMaterial(toonMaterials))#d.material
      newMesh = new THREE.Mesh( d.geometry, d.material)       
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      newMesh.position = new THREE.Vector3(Math.random() * 100, Math.random() * 100, Math.random() * 100)
      newMesh.userData = { selected: false }
      @meshData.push(newMesh)


# ジオラマが持つJSONDataの集合
class Diorama
  # プロパティでもいいかも
  stageData: undefined    # Stageを格納する変数
  modelDatum = undefined  # 単一のモデルデータ用の変数
  modelData = []          # ModelDataのリスト

  constructor: () ->

  addModelDatum: (model) ->
    modelData.push(model)
  removeModels: (targets) ->
    console.log("Removing targets from modelData...")
    
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

    
  　# setter
  setStageData: (data) ->
    console.log("Setting stageData...")
    @stageData = data
  setModelDatum: (data, subData, id) ->
    modelDatum = new window.ModelData(data, subData, id)
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
