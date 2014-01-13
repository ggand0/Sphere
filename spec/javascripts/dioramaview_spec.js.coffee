#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery-fileupload/basic
#= require threejs/build/three.js

#= require application
#= require dioramacontroller
#= require dioramas
#= require dioramaview

describe "DioramaView", ->
  data = undefined
  #json = undefined
  json = {"modeldata":{"metadata":{"formatVersion":3.2,"type":"scene","generatedBy":"convert-to-threejs.py","objects":3,"geometries":1,"materials":1,"textures":0},"urlBaseType":"relativeToScene","objects":{"Cube":{"geometry":"Geometry_33_Cube","material":"Material","position":[0,0,0],"rotation":[-1.5708,0,0],"scale":[1,1,1],"visible":true},"Lamp":{"type":"PointLight","color":16777215,"intensity":1.0,"position":[4.07625,5.90386,-1.00545],"distance":0.0},"Camera":{"type":"PerspectiveCamera","fov":28.841546,"aspect":1.0,"near":0.1,"far":99.999994,"position":[7.48113,5.34366,6.50764]}},"geometries":{"Geometry_33_Cube":{"type":"embedded","id":"Embed_33_Cube"}},"materials":{"Material":{"type":"MeshLambertMaterial","parameters":{"color":13421772,"ambient":0,"emissive":13421772,"reflectivity":1,"transparent":false,"opacity":1.0,"wireframe":false,"wireframeLinewidth":1}}},"textures":{},"embeds":{"Embed_33_Cube":{"metadata":{"vertices":8,"normals":8,"colors":0,"faces":6,"uvs":[]},"boundingBox":{"min":[-1.0,-1.000001,-1.0],"max":[1.0,1.0,1.0]},"scale":1,"materials":[],"vertices":[1,1,-1,1,-1,-1,-1,-1,-1,-1,1,-1,1,0.999999,1,0.999999,-1,1,-1,-1,1,-1,1,1],"normals":[0.577349,0.577349,-0.577349,0.577349,-0.577349,-0.577349,-0.577349,-0.577349,-0.577349,-0.577349,0.577349,-0.577349,0.577349,0.577349,0.577349,0.577349,-0.577349,0.577349,-0.577349,-0.577349,0.577349,-0.577349,0.577349,0.577349],"colors":[],"uvs":[],"faces":[35,0,1,2,3,0,0,1,2,3,35,4,7,6,5,0,4,7,6,5,35,0,4,5,1,0,0,4,5,1,35,1,5,6,2,0,1,5,6,2,35,2,6,7,3,0,2,6,7,3,35,4,0,3,7,0,4,0,3,7]}},"fogs":{},"transform":{"position":[0,0,0],"rotation":[0,0,0],"scale":[1,1,1]},"defaults":{"bgcolor":[0.667,0.667,0.667],"bgalpha":1,"camera":"Camera","fog":""}}}
  scene = undefined
  beforeEach((done)->
    #json = $.get('get_model_datum', { id: 0 })
    loader = new THREE.SceneLoader()
    loader.parse(json['modeldata'], (result) ->
      scene = result.scene
      done()
    , '')
  )

  it "should have valid members", ->

