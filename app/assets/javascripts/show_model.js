$(function() {
	THREE.ImageUtils.crossOrigin = "";

	var renderer = new THREE.WebGLRenderer({ antialias:true });
	renderer.setSize(1000, 1000);
	renderer.setClearColorHex(0xdddddd, 1);
	$('body').append(renderer.domElement);
	
	var mesh = new THREE.Mesh();	// createSceneに参照渡ししたいのでオブジェクトを入れておく
	var scene, stats, controls;
	var isMouseDown = false;
	var fov = 70;

	init();

	
	// railsで指定した、JSONが入ってるグローバル変数をSceneLoaderに投げる
	function init() {
		console.log("function loaded.");
		console.log("model_json variable:\n" + model_json);
		console.log("texture_path variable:\n" + texture_path);
		
		var loader = new THREE.SceneLoader();
		url = texture_path;
        urlBase = url.replace(/[^/]+$/g,"");
        console.log("urlBase:"+urlBase);
		loader.parse(model_json, initScene, urlBase);
	}
	
	// sceneを変数に入れるだけのコールバック関数
	function initScene(result) {
		console.log("callback function called.");
		scene = result;
		console.log(scene);

		// set stats
	    stats = new Stats();
	   	stats.domElement.style.position = 'absolute';
	    stats.domElement.style.top = '0px';
	    stats.domElement.style.left= '500px';
	    stats.domElement.style.zIndex = 100;
	    $('body').append(stats.domElement);


	  	//$(document).on('mousewheel', onDocumentMouseWheel);
		$(document).test();
		$(document).createScene(scene, mesh);
		controls = new THREE.TrackballControls(scene.camera);
		
		
		// 変数として持ちたいのでsceneから読み込んだ後再び追加
		mesh = scene.scene.children[0];
		scene.scene.children.splice(0, 1);
		scene.scene.add(mesh);
		console.log("mesh = " + mesh);
		
		animate();
	}
	
	// createScene：試験的にjQueryプラグイン化した
	
	// staticに描画するだけの関数[未使用]
	function render() {
	   	requestAnimationFrame(render);
	   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	    renderer.render(scene, scene.camera);
	};

	// マウス操作関連
	var screenW = window.innerWidth;
	var screenH = window.innerHeight;
	var spdx = 0, spdy = 0, mouseX = 0, mouseY = 0, mouseDown = false;
	$(document).on('mousemove', function(event) {
	    mouseX = event.clientX;
	    mouseY = event.clientY;
	});
	$(document).on("mousedown", function(event) {
	    mouseDown = true;
	});
	$(document).on("mouseup", function(event) {
	    mouseDown = false;
	});
	
	// meshを動かした後renderする関数
	function animate() {    
	    // 描画処理
	    requestAnimationFrame( animate );
	    renderer.render(scene.scene, scene.camera);
	    
	    // 更新処理
	    spdy =  (screenH / 2 - mouseY) / 40;
	    spdx =  (screenW / 2 - mouseX) / 40;
	    if (mouseDown){
	        mesh.rotation.x = spdy;
	        mesh.rotation.y = spdx;
	    }
	    stats.update();
	    controls.update();
	}
	function onDocumentMouseWheel( event ) {
		// jQueryのeventにwheelDeltaが無いのでoriginalEventを参照
	    fov -= event.originalEvent.wheelDeltaY * 0.05;
	    
	    //scene.camera.projectionMatrix = THREE.Matrix4.makePerspective(
	    //	fov, window.innerWidth / window.innerHeight, 1, 1100 );
	    //scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective(
	    //	fov, window.innerWidth / window.innerHeight, 1, 1100 );//15, 500 / 500
	    scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, 1000 / 1000, 1, 1100 );
	}

});
