#= require spec_helper
#= require utility

describe "DioramaView", ->
  #fixture.load('dioramanew.html', append = false)
  controller = new Sphere.DioramaController()
  view = undefined
  scene = undefined
  stageJSON = {"metadata":{"formatVersion":3.2,"type":"scene","generatedBy":"SceneExporter","objects":1,"geometries":1,"materials":1,"textures":1},"urlBaseType":"relativeToScene","objects":{"Object_3":{"geometry":"Geometry_0","material":"Material_0","position":[0,0,0],"rotation":[0,0,0],"scale":[1,1,1],"visible":true}},"geometries":{"Geometry_0":{"type":"plane","width":2000,"height":2000,"widthSegments":15,"heightSegments":15}},"materials":{"Material_0":{"type":"MeshBasicMaterial","parameters":{"color":16777215,"map":"Texture_0","reflectivity":1,"transparent":false,"opacity":1,"wireframe":false,"wireframeLinewidth":1}}},"textures":{"Texture_0":{"url":"backgrounddetailed6.jpg","repeat":[1,1],"offset":[0,0],"magFilter":"LinearFilter","minFilter":"LinearMipMapLinearFilter","anisotropy":1}},"fogs":{},"transform":{"position":[0,0,0],"rotation":[0,0,0],"scale":[1,1,1]},"defaults":{"camera":"","fog":""}}
  stageTexturePath = '/system/textures/data/Stage/0/backgrounddetailed6.jpg'
  
  beforeEach((done)->
    loader = new THREE.SceneLoader()
    loader.parse(stageJSON, (result) ->
      scene = result
      view = new Sphere.DioramaView(controller, scene, true)
      done()
    , stageTexturePath)
  )

  it "should create a valid scene", ->
    util = new Sphere.Utility()
    view.createScene(new THREE.Scene())
    scene = view.scene.scene
    
    expect(scene.children).to.exist
    expect(scene.camera).to.be.instanceof(THREE.Camera)
    expect(util.includeLight(scene.children)).to.equal(true)
    expect(util.isObjectsRotated(scene.children)).to.equal(true)
    
