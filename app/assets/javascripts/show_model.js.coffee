$ ->
  THREE.ImageUtils.crossOrigin = ""

  canvasSize = new THREE.Vector2 1024, 768
  renderer = new THREE.WebGLRenderer({ antialias:true })
  renderer.setSize(canvasSize.x , canvasSize.y)
  renderer.setClearColorHex(0xdddddd, 1)
  $renderer = $(renderer.domElement)
  $('body').append($renderer)
  
  modelJSON = undefined
  urlBase = undefined
  mesh = new THREE.Mesh()  # createSceneに参照渡ししたいのでオブジェクトを入れておく
  scene = undefined
  stats = undefined
  controls = undefined
  isMouseDown = false
  
  
  getModelDatum = () ->
    deferred = new $.Deferred()
    id = $('#id').text()

    $.get(
      'get_contents',
      { id: id }
    ).fail(() ->
      console.log("$.get failed!")
    ).then((data) ->
      console.log("request succeed.")
      console.log(data)
      
      # モデルデータを取得
      modelJSON = data['modelData']
 
      # テクスチャのルートパスを取得
      if data['texturePath']
        url = data['texturePath']?.replace(/[^/]+$/g, "")
        urlBase = url ? '' # URLの最後の"/"以下を取得(404回避)
      deferred.resolve()
    )
    return deferred.promise()
    
  
  # railsで指定した、JSONが入ってるグローバル変数をSceneLoaderに投げる
  init = () ->
    console.log("loaded.")

    getModelDatum().then(() ->
      loader = new THREE.SceneLoader()
      console.log("urlBase:" + urlBase)
      loader.parse(modelJSON, initScene, urlBase)
    )

  # sceneを変数に入れるだけのコールバック関数
  initScene = (result) ->
    console.log("callback called.")
    scene = result
    console.log(scene)

    # set stats
    stats = new Sphere.StyledStats('0px', '500px')

    # make cameras
    camera = new THREE.PerspectiveCamera(15, canvasSize.x / canvasSize.y, 0.01, 100000)
    camera.position = new THREE.Vector3(0, 0, 8)
    camera.lookAt(new THREE.Vector3(0, 0, 0))
    scene.camera = camera

    # make lights
    light = new THREE.DirectionalLight(0xcccccc)
    light.position = new THREE.Vector3(0.577, 0.577, 0.577)
    scene.scene.add(light)
    ambient = new THREE.AmbientLight(0x333333)
    scene.scene.add(ambient)
    controls = new THREE.TrackballControls(scene.camera)
    
    # 変数として持ちたいのでsceneから読み込んだ後再び追加
    mesh = scene.scene.children[0]
    scene.scene.children.splice(0, 1)
    scene.scene.add(mesh)
    console.log("mesh = " + mesh)
    
    animate()

  # meshを動かした後renderする関数
  animate = () ->    
      # 描画処理
      requestAnimationFrame( animate )
      renderer.render(scene.scene, scene.camera)
      
      # 更新処理
      stats.update()
      controls.update()
      
      
  init()
