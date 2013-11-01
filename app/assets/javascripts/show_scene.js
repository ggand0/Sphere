$(function() {
	THREE.ImageUtils.crossOrigin = "";

	var renderer = new THREE.WebGLRenderer({ antialias:true });
	renderer.setSize(500, 500);
	renderer.setClearColorHex(0x000000, 1);
	//document.body.appendChild(renderer.domElement);
	//container = document.getElementById( 'left-box' );
	container = $("#left-box")[0];
	container.appendChild(renderer.domElement);

	var mesh, scene, stats, controls;
	var selectedModelMesh, selectedModelLoaded = false;
	var isMouseDown = false, fov = 70;
	var $debugText;
	
	init();

	
	
	function init() {
		var loader = new THREE.SceneLoader();
		loader.parse(model_json, createScene, texture_path);
	}
	
	function createScene(result) {
		console.log("callback function called");
		
		// set stats
	    stats = new Stats();
	    stats.domElement.style.position = 'absolute';
	    stats.domElement.style.top = '0px';
	    stats.domElement.style.left= '500px';
	    stats.domElement.style.zIndex = 100;
	    //document.body.appendChild(stats.domElement);
	    $('body').append(stats.domElement);
		 
		// (2)create scene
		console.log(result);
		scene = result;
		 
		// (3)make cameras
		var camera = new THREE.PerspectiveCamera(15, 500 / 500, 10, 10000);
		var lookAtPos = new THREE.Vector3(camera.position.x + 1000,
			camera.position.y + 1000, 50);
		camera.position.z = 500;
		camera.up = new THREE.Vector3(0,0,1);
		camera.lookAt(lookAtPos);
		
		controls = new THREE.OrbitControls( camera, renderer.domElement ); 
		//controls.center = lookAtPos;	// lookAtPosは変わるが回転中心も変わる
		//camera.lookAt(scene.scene.position);
		scene.camera = camera;
		
		
		//$('body').on('click', onDocumentMouseClick);
		
		// draw debug info
		//debugText = document.createElement('div');
		$debugText = $('<div>');
		$debugText.addClass('debugText');
		$debugText.html("camera position:");
		//document.body.appendChild(text2);
		$('body').append($debugText);
		
		 
		// (4)make lights
		var light = new THREE.DirectionalLight(0xcccccc);
		light.position = new THREE.Vector3(0.577, 0.577, 0.577);
		scene.scene.add(light);
		var ambient = new THREE.AmbientLight(0x333333);
		scene.scene.add(ambient);


		// 変数として持ちたいのでsceneから読み込んだ後再び追加
		mesh = scene.scene.children[0];
		scene.scene.children.splice(0, 1);
		scene.scene.add(mesh);
		console.log("mesh = " + mesh);
		console.log("mesh.position:", mesh.position);
		console.log("camera.position:", camera.position);
		console.log("camera.lookat:", camera.lookAt);
		
		// 描画
		//render();
		animate();
	}

	// マウスイベント関連
	var mouseDown = false;
	$(document).on("mousedown", function(event) {
	    mouseDown = true;
	});
	$(document).on("mouseup", function(event) {
	    mouseDown = false;
	});
	function onDocumentMouseClick(event) {
		scene.scene.add(selected_model);
	    console.log("click event was called.");
	}
	function onDocumentMouseWheel( event ) {
	    fov -= event.wheelDeltaY * 0.05;
	    scene.camera.projectionMatrix = (new THREE.Matrix4())
	    	.makePerspective( fov, 500 / 500, 1, 1100 );
	}

	
	// staticに描画するだけの関数
	function render() {
	   	requestAnimationFrame(render);
	   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	    renderer.render(scene, scene.camera);
	};
	// meshを動かした後renderする関数
	function animate() {    
	    // 描画処理
	    requestAnimationFrame( animate );
	    renderer.render(scene.scene, scene.camera);
	    
	     // 更新処理
	    stats.update();
	    controls.update();
		$debugText.html("" + scene.camera.position.x.toString() + " "
			+ scene.camera.position.y.toString() + " "
			+ scene.camera.position.z.toString());
	}

});

