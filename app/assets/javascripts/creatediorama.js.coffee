$ ->
  THREE.ImageUtils.crossOrigin = ""

  canvasSize = new THREE.Vector2 1024, 768
  renderer = new THREE.WebGLRenderer { antialias:true }
  renderer.setSize(canvasSize.x , canvasSize.y)
  renderer.setClearColorHex(0x000000, 1)
  
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
  enableControl = true   # モデルが選択されている時はカメラ操作をオフにする。そのためのフラグ
  
  # Mouse picking関係
  mouseX = undefined
  mouseY = undefined
  modelObjects = new Array()
  SELECTED = undefined        # マウスで選択されたオブジェクトを格納する
  INTERSECTED = undefined
  plane = undefined           # マウスでオブジェクトを移動する際に使用する平面オブジェクト。不可視
  offset = new THREE.Vector3()
  
  
  
  
  # Railsで指定した、JSONが入ってるグローバル変数をSceneLoaderに投げる
  init = ->
    loader = new THREE.SceneLoader()
    loader.parse(modelJSON, createScene, texturePath)
    loader.parse(selectedModel, callBack, '')
    #loader.load("terrain0.json", createScene)
    
  # SceneLoaderが返したModelオブジェクトを変数へ入れる
  callBack = (result) ->
    console.log("model callback function called.")
    # sceneで返ってくるので面倒だ
    selectedModelMesh = result.scene.children[0]
    selectedModelLoaded = true
    console.log(selectedModelLoaded)

  # SceneLoaderが返したStageオブジェクトにいろいろ追加する
  createScene = (result) ->
    console.log("callback function called.")
    # (2)create scene
    console.log(result)
    scene = result

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

    # make lights
    light = new THREE.DirectionalLight(0xcccccc)
    light.position = new THREE.Vector3(0.577, 0.577, 1000)
    scene.scene.add(light)
    ambient = new THREE.AmbientLight(0x333333)
    scene.scene.add(ambient)
    
    # draw debug info
    #debugText = document.createElement('div')
    $debugText = $('<div>')
    $debugText.addClass('debugText')
    $debugText.html("camera position:")
    #document.body.appendChild(text2)
    $('body').append($debugText)
    
    # 変数として持ちたいのでsceneから読み込んだ後再び追加
    mesh = scene.scene.children[0]
    scene.scene.children.splice(0, 1)
    scene.scene.add(mesh)
    
    # マウスピッキング移動用に平面オブジェクトを作成
    plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 8, 8 ),
      new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: true, wireframe: true } ) )
    #plane.visible = false
    scene.scene.add( plane )
    
    # y軸を上にしたいので、scene内のオブジェクトを全て回転させる
    #for (i=0 i < scene.scene.children.length i++) {
    for i in scene.scene.children
      #console.log(i.rotation)
      #console.log(i.rotation.y)
      #scene.scene.children[i].rotation.y = -90 * Math.PI / 180
      i.rotation.x = -90 * Math.PI / 180

    # 描画
    animate()
  

  # ロード開始
  init()
  
  
  # マウスイベント追加
  $(document).on "mousedown", (event) ->
    # Camera control
    isMouseDown = true
    if enableControl
      onMouseDownTheta = theta
      onMouseDownPhi = phi
      onMouseDownPosition.x = event.originalEvent.clientX
      onMouseDownPosition.y = event.originalEvent.clientY
      scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
    
    
    # Picking ray detection
    rect = event.originalEvent.target.getBoundingClientRect()
    # マウス位置(2D)
    mouseX = event.originalEvent.clientX - rect.left
    mouseY = event.originalEvent.clientY - rect.top
    # マウス位置(3D)
    mouseX = (mouseX / canvasSize.x) * 2 - 1
    mouseY =-(mouseY / canvasSize.y) * 2 + 1
    # マウスベクトル
    vector = new THREE.Vector3(mouseX, mouseY, 1)
    projector.unprojectVector( vector, scene.camera )
    raycaster = new THREE.Raycaster( scene.camera.position,
      vector.sub( scene.camera.position ).normalize() )
    intersects = raycaster.intersectObjects(modelObjects)

    #console.log(vector)
    #console.log(modelObjects)
    console.log(intersects)
    
    # 何かと交差していたら、対象を選択中のオブジェクトとしてSELECTEDへ保存する
    if intersects.length > 0
      enableControl = false
      intersects[0].object.material.color.setHex( Math.random() * 0xffffff )
      SELECTED = intersects[0].object
      console.log(SELECTED)
      # from sample
      intersects = raycaster.intersectObject( plane )
      offset.copy( intersects[0].point ).sub( plane.position )
    
  
  $(document).on "mouseup", (event) ->
    event.preventDefault()
    console.log("mouseup")
    console.log(INTERSECTED)
    
    # Mouse picking
    if INTERSECTED
      plane.position.copy( INTERSECTED.position )
      SELECTED = null
      console.log("none is selected.")
      
    # Camera control
    isMouseDown = false
    enableControl = true
    if enableControl
      onMouseDownPosition.x = event.originalEvent.clientX - onMouseDownPosition.x
      onMouseDownPosition.y = event.originalEvent.clientY - onMouseDownPosition.y
      if onMouseDownPosition.length() > 5
        return
      scene.camera.lookAt(new THREE.Vector3(0, 0, 0))

  $(document).on "mousemove", (event) ->
    # Camera control
    event.preventDefault()
    # オブジェクトが選択されている時は動かさない
    if enableControl
      if isMouseDown
        # 長い計算式はJavascriptの方が見やすいと判断した（式の途中で改行出来るという点で）
        `
        theta = - ( ( event.originalEvent.clientX - onMouseDownPosition.x ) * 0.5 )
                + onMouseDownTheta
        phi = ( ( event.originalEvent.clientY - onMouseDownPosition.y ) * 0.5 )
              + onMouseDownPhi
        phi = Math.min( 180, Math.max( 0, phi ) )
  
        scene.camera.position.x = radious * Math.sin( theta * Math.PI / 360 )
                            * Math.cos( phi * Math.PI / 360 )
        scene.camera.position.y = radious * Math.sin( phi * Math.PI / 360 )
        scene.camera.position.z = radious * Math.cos( theta * Math.PI / 360 )
                            * Math.cos( phi * Math.PI / 360 )
        scene.camera.updateMatrix()
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
    
    
    # Dragging objects
    #mouseX = ( event.clientX / window.innerWidth ) * 2 - 1
    #mouseY = - ( event.clientY / window.innerHeight ) * 2 + 1
    rect = event.target.getBoundingClientRect()
    # マウス位置(2D)
    mouseX = event.clientX - rect.left
    mouseY = event.clientY - rect.top
    # マウス位置(3D)
    mouseX = (mouseX / canvasSize.x) * 2 - 1
    mouseY =-(mouseY / canvasSize.y) * 2 + 1
    
    vector = new THREE.Vector3( mouseX, mouseY, 0.5 )
    projector.unprojectVector( vector, scene.camera )
    raycaster = new THREE.Raycaster( scene.camera.position, vector.sub( scene.camera.position ).normalize() )
    if SELECTED
      # planeはカメラ方向を向かせているので絶対交差するはず
      intersects = raycaster.intersectObject( plane )
      SELECTED.position.copy( intersects[0].point.sub( offset ) )
      return
      
    intersects = raycaster.intersectObjects( modelObjects )
    if intersects.length > 0 
      if INTERSECTED != intersects[0].object
        if INTERSECTED
          INTERSECTED.material.color.setHex( INTERSECTED.currentHex )

        INTERSECTED = intersects[0].object
        INTERSECTED.currentHex = INTERSECTED.material.color.getHex()
        plane.position.copy( INTERSECTED.position )
        plane.lookAt( scene.camera.position )
    else
      if INTERSECTED
        INTERSECTED.material.color.setHex( INTERSECTED.currentHex )
      INTERSECTED = null
      #container.style.cursor = 'auto'


  $(document).on "mousewheel", (event) ->
    if enableControl
      radious -= event.originalEvent.wheelDeltaY
      scene.camera.position.x = radious * Math.sin(theta * Math.PI / 360) * Math.cos(phi * Math.PI / 360)
      scene.camera.position.y = radious * Math.sin( phi * Math.PI / 360 )
      scene.camera.position.z = radious * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
      scene.camera.updateMatrix()
  
  
  # モデルをシーンに追加する
  addModel = (event) ->
    if selectedModelLoaded
      newMesh = new THREE.Mesh( selectedModelMesh.geometry,
        new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ))
      
      newMesh.scale = new THREE.Vector3(10, 10, 10)
      newMesh.position = new THREE.Vector3(Math.random() * 100, Math.random() * 100, Math.random() * 100)
      #scene.scene.add(selectedModelMesh)
      scene.scene.add(newMesh)
      modelObjects.push(newMesh)  # 判定用に使用する、モデルのみを入れる配列
      #console.log(newMesh)
      getModelTransforms()

  # モデルの位置データをViewのフォームに入力する
  insertTransforms = (event) ->
    console.log("inserting transforms to form.")
    #console.log(modelJSON)
    #console.log(JSON.stringify(modelJSON))
    
    positions = getModelTransforms()
    console.log(positions)
    console.log(JSON.stringify(positions))
    $(document).ready () ->
      $("#transforms_field").val(JSON.stringify(positions))
      #$("#stage_field").val(JSON.stringify(modelJSON))
    
  #$('body').on('click', addModel)
  $("body").keypress(addModel)  # space bar押下時に変更
  $('body').on('dblclick', insertTransforms)

  
  # 配置されたモデルの位置を取得しarrayに格納して返す
  getModelTransforms = ->
    array = []
    
    i = -1
    #for (m in scene.scene.children) {# 全てstring
    #for (m in scene.objects) {
    #for i in scene.scene.children
    
    # i in ...childrenだと細かな型判定が出来ないので直接参照する形にした
    while i < scene.scene.children.length
    #for i in range(scene.scene.children.length) 
      #console.log(typeof(scene.scene.children[i]))
      #console.log(typeof(i))
      #console.log(scene.scene.children[i])
      i += 1
      if i == 0
        continue# stageだから
      
      if scene.scene.children[i] instanceof THREE.Mesh
      #if (typeof(scene.scene.children[i]) == THREE.Mesh) {
        #console.log(scene.scene.children[i])
        s = JSON.stringify(scene.scene.children[i].position.toArray())
        array.push(s)
      
    return array

  # Railsのcontroller内のactionにデータを送るテスト
  send = (event) ->
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
  

  # meshを動かした後renderする関数
  animate = ->  
    # 描画処理
    requestAnimationFrame( animate )
    renderer.render(scene.scene, scene.camera)
      
    # 更新処理
    stats.update()
    #controls.update()
    ###$debugText.text("" + scene.camera.position.x.toString() + " "
      + scene.camera.position.y.toString() + " "
      + scene.camera.position.z.toString())###
    $debugText.text(INTERSECTED)
  