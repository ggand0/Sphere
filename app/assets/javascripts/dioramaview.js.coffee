# シーン生成・イベント周りを担当する
class DioramaView
  canvasSize = new THREE.Vector2 1024, 768
  renderer = new THREE.WebGLRenderer { antialias:true }
  renderer.setSize(canvasSize.x , canvasSize.y)
  renderer.setClearColorHex(0xffffff, 1)
  
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
  enableControl = true          # モデルが選択されている時はカメラ操作をオフにする。そのためのフラグ
  
  # Mouse picking関係
  mouseX = undefined
  mouseY = undefined
  modelObjects = new Array()
  isSelected = undefined        # マウスで選択されたオブジェクトを格納する
  isIntersected = undefined
  plane = undefined             # マウスでオブジェクトを移動する際に使用する平面オブジェクト。不可視
  offset = new THREE.Vector3()
  
  # コントローラへの参照
  dioramaController = undefined
  
  
  # コンストラクタ：
  # stageオブジェクトを受け取ってsceneを生成する
  constructor: (controller, stageData, enableControl) ->
    dioramaController = controller
    #scene = this.controller.get()
    scene = stageData
    console.log("dioramaView's scene:")
    console.log(controller)
    console.log(dioramaController)
    console.log(stageData)
    console.log(scene)
    
    createScene()
    addEvents.call(this, enableControl)
    

  # 既に設定されたsceneにいろいろ追加する、シーン生成関数
  createScene = () ->
    console.log("Creating scene...")
    # tmp
    for obj in scene.scene.children
      scene.scene.remove(obj)
    #scene.objects.remove(scene.objects[0])
    delete scene.objects.Object_3
    console.log(typeof scene.objects)
    #scene.objects.splice(0, 1)
    console.log(scene)
    
    # FPS表示用のインスタンス生成＆bodyに追加
    stats = new window.StyledStats()

    # make cameras
    camera = new THREE.PerspectiveCamera(15, canvasSize.x / canvasSize.y, 10, 100000)
    lookAtPos = new THREE.Vector3(camera.position.x + 1000,
      camera.position.y + 1000, 50)
    
    # ToDo:ここの計算式を整理する
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
    
    # generate grid plane
    geometry = new THREE.Geometry();
    geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( - 500, 0, 0 ) ) )
    geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( 500, 0, 0 ) ) )
    linesMaterial = new THREE.LineBasicMaterial( 0x000000, 0.2 )
    #linesMaterial = new THREE.LineBasicMaterial( 0xcccccc, 1.0 )
    #for ( var i = 0; i <= 20; i ++ ) {
    for i in [0..20]
      line = new THREE.Line( geometry, linesMaterial )
      line.position.z = ( i * 50 ) - 500
      scene.scene.add( line )

      line = new THREE.Line( geometry, linesMaterial )
      line.position.x = ( i * 50 ) - 500
      line.rotation.y = 90 * Math.PI / 180
      scene.scene.add( line )
    plane = new THREE.Mesh(new THREE.PlaneGeometry(2000, 2000), new THREE.MeshBasicMaterial({color: 0xcccccc}));
    plane.rotation.x = -90 * Math.PI / 180# 回転
    scene.scene.add( plane )
    
    # draw debug info
    $debugText = $('<div>')
    $debugText.addClass('debugText')
    $debugText.text("camera position:")
    $debugText.css({top: 200, left: 200, position:'absolute'})
    $('body').append($debugText)
    
    # mesh変数として持っておきたいのでsceneから読み込んだ後再び追加
    mesh = scene.scene.children[0]
    scene.scene.children.splice(0, 1)
    scene.scene.add(mesh)
    
    # オブジェクト操作用に、平面オブジェクトを作成
    plane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 8, 8 ),
      new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: true, wireframe: true } ) )
    #plane.visible = false
    scene.scene.add( plane )
    
    # y軸を上にしたいので、scene内のオブジェクトを全て回転させる
    for i in scene.scene.children
      i.rotation.x = -90 * Math.PI / 180



  # Render&Update関数
  animate: =>
    # Render
    requestAnimationFrame( @animate )
    renderer.render(scene.scene, scene.camera)
      
    # Update
    stats.update()
    #controls.update()
    $debugText.text("#{scene.camera.position.x} #{scene.camera.position.y} #{scene.camera.position.z}")
    #$debugText.text(isIntersected)
    
  
  # カメラ操作関連のイベントを追加する
  addCameraEvents= () ->
    $(document).on "mousedown", (event) ->
      # Camera control
      isMouseDown = true
      if enableControl
        onMouseDownTheta = theta
        onMouseDownPhi = phi
        onMouseDownPosition.x = event.originalEvent.clientX
        onMouseDownPosition.y = event.originalEvent.clientY
        scene.camera.lookAt(new THREE.Vector3(0, 0, 0))
        
    $(document).on "mouseup", (event) ->
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

    $(document).on "mousewheel", (event) ->
      if enableControl
        radius -= event.originalEvent.wheelDeltaY
        scene.camera.position.x = radius * Math.sin(theta * Math.PI / 360) * Math.cos(phi * Math.PI / 360)
        scene.camera.position.y = radius * Math.sin( phi * Math.PI / 360 )
        scene.camera.position.z = radius * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 )
        scene.camera.updateMatrix()
        
    
  # モデル追加・操作関連のイベントを追加する
  addModelEvents= () ->
    $(document).on "mousedown", (event) ->
    #$container.on "mousedown", (event) ->
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
        #intersects[0].object.material.color.setHex( Math.random() * 0xffffff )
        isSelected = intersects[0].object
        
        # 選択フラグを操作
        for obj in scene.scene.children
          if obj is isSelected
            if obj.userData['selected'] is true
              obj.userData = { selected: false }
            else
              obj.userData = { selected: true }
        
        
        console.log(isSelected)
        # from sample
        intersects = raycaster.intersectObject( plane )
        offset.copy( intersects[0].point ).sub( plane.position )
        
            
    $(document).on "mouseup", (event) ->
      console.log("mouseup")
      console.log(isIntersected)
      
      # Mouse picking
      if isIntersected
        plane.position.copy( isIntersected.position )
        isSelected = null
        console.log("none is selected.")
        
    $(document).on "mousemove", (event) ->
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
        console.log(isSelected)
        # planeはカメラ方向を向かせているので絶対交差するはず
        intersects = raycaster.intersectObject( plane )
        isSelected.position.copy( intersects[0].point.sub( offset ) )
        return
        
      intersects = raycaster.intersectObjects( modelObjects )
      if intersects.length > 0
        if isIntersected isnt intersects[0].object
          #if isIntersected
            #console.log(isIntersected)
            #isIntersected.material.color.setHex( isIntersected.currentHex )
  
          isIntersected = intersects[0].object
          #isIntersected.currentHex = isIntersected.material.color.getHex()
          
          
          # オブジェクトを動かす基準にする平面を、カメラの方へ向ける（並行に置く）
          plane.position.copy( isIntersected.position )
          plane.lookAt( scene.camera.position )
      else
        #if isIntersected
          #console.log(isIntersected)
          #isIntersected.material.color.setHex( isIntersected.currentHex )
        isIntersected = null
        #container.style.cursor = 'auto'
    
    # その他のイベントを追加
    $('body').on('dblclick', dioramaController.insertTransforms)
    $("body").keypress(dioramaController.handleKeyEvents)
    #$container.keypress(dioramaController.handleKeyEvents)
    #$renderer.keypress(dioramaController.handleKeyEvents)
    #$(renderer.domElement).keypress(dioramaController.handleKeyEvents)
    #$("#left-box").keypress(dioramaController.handleKeyEvents)
    #$("#left-box").on('keypress', dioramaController.handleKeyEvents)
    #$("#left-box").keypress((event) ->
    #renderer.context.canvas.addEventListener("keypress", (event) ->
    console.log("SELECTOR TEST ")
    console.log(renderer.context)
    console.log($("#left-box"))
    console.log($('body'))
    
    
    

  # マウスイベントを追加する
  addEvents= (addControlEvents) ->
    console.log("Adding events...")
    console.log(dioramaController)
    console.log(dioramaController.addModel)
    
    addCameraEvents.call(this)
    if addControlEvents
      addModelEvents.call(this)
        
  
  # シーンにあるオブジェクトのやりとり
  addModelToScene: (newMesh) ->
    scene.scene.add(newMesh)
    modelObjects.push(newMesh)
  removeModel: (target) ->
    for obj in scene.scene.children
      if obj is target
        scene.scene.remove(obj)
  removeModels: (targets) ->
    ###
    dels = []
    for obj in scene.scene.children
      for t in targets
        if obj is t
          dels.push(obj)
    ###
    dels = (obj for obj in scene.scene.children when obj is t for t in targets)
    console.log(dels)
    for d in dels
      scene.scene.remove(d[0])
      
  getAllSceneObjects: () ->
    return scene.scene.children
  getSceneObjects: (type) ->
    array = (value for value in scene.scene.children when value instanceof type)
    return array
  getScene: ->
    return scene;
  setSceneObjects: (objects) ->
    scene.scene.children = objects

window.DioramaView = window.DioramaView or DioramaView