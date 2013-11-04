$ ->
  THREE.ImageUtils.crossOrigin = ""

  canvasSize = new THREE.Vector2(1024, 768)
  renderer = new THREE.WebGLRenderer({ antialias:true })
  renderer.setSize(canvasSize.x , canvasSize.y)
  renderer.setClearColorHex(0x000000, 1)
  
  #container = $("#left-box")[0]
  #container.appendChild(renderer.domElement)
  $container = $("#left-box")
  $renderer = $(renderer.domElement)
  $container.append($renderer)

  mesh = undefined
  scene = undefined
  stats = undefined
  controls = undefined
  selectedModelMesh = undefined
  selectedModelLoaded = false
  isMouseDown = false
  fov = 70
  $debugText = undefined
  
  # カメラ関係
  ray = undefined
  mouse3D = undefined
  projector = new THREE.Projector()
  onMouseDownPosition = new THREE.Vector2()
  onMouseDownPhi = 60
  onMouseDownTheta = 45
  radious = 1000
  theta = 45
  phi = 60
  modelObjects = new Array()
  
  
  
  
  init = ->
    console.log("loaded.")
    console.log("modelJSON variable:")
    console.log(modelJSON)
    console.log("texturePath variable:\n" + texturePath)
    loader = new THREE.SceneLoader()
    loader.parse(modelJSON, createScene, texturePath)
    
    # sceneが格納されるより先に実行されてしまうのでcreateScene内で実行する
    #loader.parse(selectedModel, callBack, '')

  callBack = (result) ->
    console.log("model callback called.")
  
    selectedModelMesh = result.scene.children[0]
    selectedModelLoaded = true
  
    console.log("positions:")
    console.log(modelTransforms)
  
    # Convert JSON to array
    positions = []
    $.each(modelTransforms, (i, obj) ->
      #console.log(obj)
      positions.push(JSON.parse(obj))
    )
    console.log(positions)
  
    # modelTransformsで与えられる位置に配置する 
    i = 0
    #for (i=0 i < positions.length i++) {
    while i < positions.length
      newMesh = new THREE.Mesh( selectedModelMesh.geometry,
        new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ))
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      
      #console.log(positions[i])
      pos = new THREE.Vector3().fromArray(positions[i])
      console.log(pos)
      newMesh.position = pos
      scene.scene.add(newMesh)
      modelObjects.push(newMesh)  # 判定用に使用する、モデルのみを入れる配列
      
      i++
    
    console.log(scene)
  
  createScene = (result) ->
    console.log("callback called.")
    # create scene
    console.log(result)
    scene = result
    
    # Modelのparse開始
    loader = new THREE.SceneLoader()
    loader.parse(selectedModel, callBack, '')
    
    
    # set stats
    stats = new Stats()
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.top = '0px'
    stats.domElement.style.left= '500px'
    stats.domElement.style.zIndex = 100
    $('body').append(stats.domElement)

    # make cameras
    camera = new THREE.PerspectiveCamera(15, canvasSize.x / canvasSize.y, 10, 100000)
    lookAtPos = new THREE.Vector3(camera.position.x + 1000,
      camera.position.y + 1000, 50)
    #camera.position.set(0, 200, 0)
    camera.position.x = radious * Math.sin( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
    camera.position.y = radious * Math.sin( phi * Math.PI / 360 )
    camera.position.z = radious * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
    ray = new THREE.Ray(camera.position, null)
    scene.camera = camera
    
    # old try
    #controls = new THREE.EditorControls( camera, renderer.domElement ) 
    ###controls = new THREE.TrackballControls( camera, renderer.domElement )
    controls.rotateSpeed = 5.0
    controls.zoomSpeed = 1.2
    controls.panSpeed = 0.8
    controls.noZoom = false
    controls.noPan = false
    controls.staticMoving = true
    controls.dynamicDampingFactor = 0.3###
    #controls.center = lookAtPos  # lookAtPosは変わるが回転中心も変わる
    #camera.lookAt(scene.scene.position)
    
  
    # make lights
    light = new THREE.DirectionalLight(0xcccccc)
    light.position = new THREE.Vector3(0.577, 0.577, 1000)
    scene.scene.add(light)
    ambient = new THREE.AmbientLight(0x333333)
    scene.scene.add(ambient)
    
    # draw debug info
    $debugText = $('<div>')
    $debugText.addClass('debugText')
    $debugText.text("camera position:")
    $('body').append($debugText)
    
    # 変数として持ちたいのでsceneから読み込んだ後再び追加
    mesh = scene.scene.children[0]
    scene.scene.children.splice(0, 1)
    scene.scene.add(mesh)
    
    # y軸を上にしたいので回転させる
    #for (i=0 i < scene.scene.children.length i++) {
    for i in scene.scene.children
      console.log(i.rotation)
      console.log(i.rotation.y)
      #scene.scene.children[i].rotation.y = -90 * Math.PI / 180
      i.rotation.x = -90 * Math.PI / 180
    
    # 描画
    animate()


  init()
  
  # マウスイベント追加
  $(document).on("mousedown", (event) ->
    isMouseDown = true
    onMouseDownTheta = theta
    onMouseDownPhi = phi
    onMouseDownPosition.x = event.originalEvent.clientX
    onMouseDownPosition.y = event.originalEvent.clientY
    
    #animate()
    scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
    
    
    # Picking ray detection
    rect = event.target.getBoundingClientRect();
    # マウス位置(2D)
    mouseX = event.clientX - rect.left;
    mouseY = event.clientY - rect.top;
    # マウス位置(3D)
    mouseX = (mouseX / canvasSize.x) * 2 - 1;
    mouseY =-(mouseY / canvasSize.y) * 2 + 1;
    # マウスベクトル
    vector = new THREE.Vector3(mouseX, mouseY, 1);
    projector.unprojectVector( vector, scene.camera )
    raycaster = new THREE.Raycaster( scene.camera.position,
      vector.sub( scene.camera.position ).normalize() )
    intersects = raycaster.intersectObjects(modelObjects)

    #console.log(vector)
    console.log(modelObjects)
    console.log(intersects)
    if intersects.length > 0
      intersects[0].object.material.color.setHex( Math.random() * 0xffffff )

  )
  $(document).on("mouseup", (event) ->
    isMouseDown = false
    onMouseDownPosition.x = event.originalEvent.clientX - onMouseDownPosition.x
    onMouseDownPosition.y = event.originalEvent.clientY - onMouseDownPosition.y
    
    if onMouseDownPosition.length() > 5
      return
    #animate()
    scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
  )
  $(document).on "mousemove", (event) ->
    event.preventDefault()
    if isMouseDown
      # 長い計算式はJavascriptの方が見やすいと判断した（式の途中で改行出来るという点で）
      `
      theta = - ( ( event.originalEvent.clientX - onMouseDownPosition.x ) * 0.5 )
              + onMouseDownTheta;
      phi = ( ( event.originalEvent.clientY - onMouseDownPosition.y ) * 0.5 )
            + onMouseDownPhi;
      phi = Math.min( 180, Math.max( 0, phi ) );

      scene.camera.position.x = radious * Math.sin( theta * Math.PI / 360 )
                          * Math.cos( phi * Math.PI / 360 );
      scene.camera.position.y = radious * Math.sin( phi * Math.PI / 360 );
      scene.camera.position.z = radious * Math.cos( theta * Math.PI / 360 )
                          * Math.cos( phi * Math.PI / 360 );
      scene.camera.updateMatrix();
      `

    mouse3D = projector.unprojectVector(
      new THREE.Vector3(
          ( event.originalEvent.clientX / renderer.domElement.width ) * 2 - 1,
          - ( event.originalEvent.clientY / renderer.domElement.height ) * 2 + 1,
          0.5
      ),
      scene.camera
    )
    #ray.direction = mouse3D.subSelf( scene.camera.position ).normalize()
    ray.direction = mouse3D.sub( scene.camera.position ).normalize()
    
    #render()
    scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
    
  $(document).on("mousewheel", (event) ->
    ###fov -= event.wheelDeltaY * 0.05
      scene.camera.projectionMatrix = (
        new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 )###
    radious -= event.originalEvent.wheelDeltaY

    scene.camera.position.x = radious * Math.sin( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
    scene.camera.position.y = radious * Math.sin( phi * Math.PI / 360 )
    scene.camera.position.z = radious * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
    scene.camera.updateMatrix()
  )
  
  # モデル位置取得関連
  getModelTransforms = ->
    array = []
    i = 0
    
    # i in scene.scene.childrenだと細かな型判定が出来ないので直接参照する形にした
    while i < scene.scene.children.length
    #for i in range(scene.scene.children.length)
      #console.log(typeof(scene.scene.children[i]))
      #console.log(typeof(i))
      #console.log(scene.scene.children[i])
      
      if i == 0
        i++
        continue# stageだから
      else if scene.scene.children[i] instanceof THREE.Mesh
      #if (typeof(scene.scene.children[i]) == THREE.Mesh) {
        console.log(scene.scene.children[i])
        #array = []
        s = JSON.stringify(scene.scene.children[i].position.toArray())
        array.push(s)
      i++
      
    return array
    
  send = (event) ->
    console.log(scene.objects)
    console.log(scene.scene.children)
    console.log("begin ajax request.")
    ###
    $.ajax({
        url: 'ready',
        type: 'POST',
        data: {
          code: getModelTransforms()
          #code: "data from javascript."
        },
        success: function(data, event, status, xhr) {
          console.log("request succeed.")
        },
        error: function(event, data, status, xhr) {
          console.log("request failed.")
        }
      })
    ###
  insertTransforms = (event) ->
    console.log("inserting transforms to form.")
    positions = getModelTransforms
    $(document).ready () ->
      $("#transforms_field").val(JSON.stringify(positions))
  

  # 描画関連
  render = ->
      requestAnimationFrame(render)
      renderer.render(scene, scene.camera)
  
  # meshを動かした後renderする関数
  animate = ->
      requestAnimationFrame( animate )
      renderer.render(scene.scene, scene.camera)
      
       # 更新処理
      stats.update()
      #controls.update()
    $debugText.text("" + scene.camera.position.x.toString() + " "
      + scene.camera.position.y.toString() + " "
      + scene.camera.position.z.toString())
  

