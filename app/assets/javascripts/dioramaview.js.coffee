# シーン生成・イベント周りを担当する
class DioramaView
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
  radius = 1000
  theta = 45
  phi = 60
  enableControl = true   # モデルが選択されている時はカメラ操作をオフにする。そのためのフラグ
  
  # Mouse picking関係
  mouseX = undefined
  mouseY = undefined
  modelObjects = new Array()
  isSelected = undefined        # マウスで選択されたオブジェクトを格納する
  isIntersected = undefined
  plane = undefined             # マウスでオブジェクトを移動する際に使用する平面オブジェクト。不可視
  offset = new THREE.Vector3()
  
  dioramaController = undefined
  
  # stageオブジェクトを受け取ってsceneを生成する
  constructor: (controller, stageData) ->
    dioramaController = controller
    #scene = this.controller.get()
    scene = stageData
    console.log("dioramaView's scene:")
    console.log(controller)
    console.log(dioramaController)
    console.log(stageData)
    console.log(scene)
    createScene()
    
  # 既に設定されたsceneにいろいろ追加する
  createScene = () ->
    console.log("Creating scene...")
    # (2)create scene
    #console.log(result)
    #scene = result

    # FPS表示用のインスタンス生成＆bodyに追加
    stats = new window.StyledStats()

    # make cameras
    camera = new THREE.PerspectiveCamera(15, canvasSize.x / canvasSize.y, 10, 100000)
    lookAtPos = new THREE.Vector3(camera.position.x + 1000,
      camera.position.y + 1000, 50)
    #camera.position.set(0, 200, 0)
    camera.position.x = radius * Math.sin( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
    camera.position.y = radius * Math.sin( phi * Math.PI / 360 )
    camera.position.z = radius * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
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
    $debugText.text("camera position:")
    $debugText.css({top: 200, left: 200, position:'absolute'})
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
    
    # マウスイベント等を追加
    addEvents.call(this)
    
    # 描画
    #animate.call(this)

  # meshを動かした後renderする関数
  animate: =>
    # 描画処理
    #console.log(@animate)
    #console.log(this.animate)
    requestAnimationFrame( @animate )
    renderer.render(scene.scene, scene.camera)
      
    # 更新処理
    stats.update()
    #controls.update()
    $debugText.text("#{scene.camera.position.x} #{scene.camera.position.y} #{scene.camera.position.z}")
    #$debugText.text(isIntersected)
    
  
  
  # マウスイベントを追加する
  addEvents= (addControlEvents) ->
    console.log("Adding events...")
    console.log(dioramaController)
    console.log(dioramaController.addModel)
    $("body").keypress(dioramaController.addModel)
    $('body').on('dblclick', dioramaController.insertTransforms)
    
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
      
      # 何かと交差していたら、対象を選択中のオブジェクトとしてisSelectedへ保存する
      if intersects.length > 0
        enableControl = false
        intersects[0].object.material.color.setHex( Math.random() * 0xffffff )
        isSelected = intersects[0].object
        console.log(isSelected)
        # from sample
        intersects = raycaster.intersectObject( plane )
        offset.copy( intersects[0].point ).sub( plane.position )
      
    
    $(document).on "mouseup", (event) ->
      event.preventDefault()
      console.log("mouseup")
      console.log(isIntersected)
      
      # Mouse picking
      if isIntersected
        plane.position.copy( isIntersected.position )
        isSelected = null
        console.log("none is selected.")
        
      # Camera control
      isMouseDown = false
      enableControl = true
      if enableControl
        onMouseDownPosition.x = event.originalEvent.clientX - onMouseDownPosition.x
        onMouseDownPosition.y = event.originalEvent.clientY - onMouseDownPosition.y
        return if onMouseDownPosition.length() > 5
        scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
  
    $(document).on "mousemove", (event) ->
      # Camera control
      event.preventDefault()
      # オブジェクトが選択されている時は動かさない
      if enableControl
        if isMouseDown
          theta = - ( ( event.originalEvent.clientX - onMouseDownPosition.x ) * 0.5 ) +
                  onMouseDownTheta
          phi = ( ( event.originalEvent.clientY - onMouseDownPosition.y ) * 0.5 ) +
                onMouseDownPhi
          phi = Math.min( 180, Math.max( 0, phi ) )
    
          scene.camera.position.x = radius * Math.sin( theta * Math.PI / 360 ) *
                              Math.cos( phi * Math.PI / 360 )
          scene.camera.position.y = radius * Math.sin( phi * Math.PI / 360 )
          scene.camera.position.z = radius * Math.cos( theta * Math.PI / 360 ) *
                              Math.cos( phi * Math.PI / 360 )
          scene.camera.updateMatrix()
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
      if isSelected
        # planeはカメラ方向を向かせているので絶対交差するはず
        intersects = raycaster.intersectObject( plane )
        isSelected.position.copy( intersects[0].point.sub( offset ) )
        return
        
      intersects = raycaster.intersectObjects( modelObjects )
      if intersects.length > 0
        if isIntersected isnt intersects[0].object
          if isIntersected
            isIntersected.material.color.setHex( isIntersected.currentHex )
  
          isIntersected = intersects[0].object
          isIntersected.currentHex = isIntersected.material.color.getHex()
          # オブジェクトを動かす基準にする平面を、カメラの方へ向ける（並行に置く）
          plane.position.copy( isIntersected.position )
          plane.lookAt( scene.camera.position )
      else
        if isIntersected
          isIntersected.material.color.setHex( isIntersected.currentHex )
        isIntersected = null
        #container.style.cursor = 'auto'
  
  
    $(document).on "mousewheel", (event) ->
      if enableControl
        radius -= event.originalEvent.wheelDeltaY
        scene.camera.position.x = radius * Math.sin(theta * Math.PI / 360) * Math.cos(phi * Math.PI / 360)
        scene.camera.position.y = radius * Math.sin( phi * Math.PI / 360 )
        scene.camera.position.z = radius * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
        scene.camera.updateMatrix()
        
  addModelToScene: (newMesh) ->
    scene.scene.add(newMesh)
    modelObjects.push(newMesh)
    
  getSceneObjects: () ->
    return scene.scene.children

window.DioramaView = window.DioramaView or DioramaView