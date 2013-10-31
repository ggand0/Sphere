$(function() {
	THREE.ImageUtils.crossOrigin = "";

	var renderer = new THREE.WebGLRenderer({ antialias:true });
	renderer.setSize(500, 500);
	renderer.setClearColorHex(0x000000, 1);
	//document.body.appendChild(renderer.domElement);
	// divに追加しておく
	container = document.getElementById( 'left-box' );
	container.appendChild(renderer.domElement);

	init();


	var mesh, scene, stats, controls, text2;
	var selectedModelMesh, selectedModelLoaded = false;
	var isMouseDown = false;
	var fov = 70;
	var windowHalfX = window.innerWidth / 2;
	var windowHalfY = window.innerHeight / 2;
	
	
	function init() {
		console.log("function loaded.");
		console.log("model_json variable:");
		console.log(model_json);
		console.log("texture_path variable:\n" + texture_path);
		var loader = new THREE.SceneLoader();
		loader.parse(model_json, createScene, texture_path);
		loader.parse(selected_model, callBack, '');
	    //loader.load("terrain0.json", createScene);
	}
	
	function callBack(result) {
		console.log("model callback function called.");
		// sceneで返ってくるので面倒だ
		selectedModelMesh = result.scene.children[0];
		selectedModelLoaded = true;
	}
	function createScene(result) {
		console.log("callback function called.");
		
		// set stats
	    stats = new Stats();
	    stats.domElement.style.position = 'absolute';
	    stats.domElement.style.top = '0px';
	    stats.domElement.style.left= '500px';
	    stats.domElement.style.zIndex = 100;
	    document.body.appendChild(stats.domElement);
		 
		// (2)create scene
		console.log(result);
		scene = result;
		 
		// (3)make cameras
		var camera = new THREE.PerspectiveCamera(15, 500 / 500, 10, 10000);
		camera.position.z = 500;
		//camera.lookAt(new THREE.Vector3(100, 0, camera.position.z));
		camera.up = new THREE.Vector3(0,0,1);
		var lookAtPos = new THREE.Vector3(camera.position.x + 1000,
			camera.position.y + 1000, 50);
		camera.lookAt(lookAtPos);
		
		controls = new THREE.OrbitControls( camera, renderer.domElement ); 
		//controls.center = lookAtPos;	// lookAtPosは変わるが回転中心も変わる
		//camera.lookAt(scene.scene.position);
		scene.camera = camera;
	
	
		// add mouse click event
		document.addEventListener('click', onDocumentMouseClick, false);
		document.addEventListener('dblclick', insertTransforms, false);
	
		
		// draw debug info
		text2 = document.createElement('div');
		text2.style.position = 'absolute';
		//text2.style.zIndex = 1;    // if you still don't see the label, try uncommenting this
		text2.style.width = 100;
		text2.style.height = 100;
		//text2.style.backgroundColor = "blue";
		text2.innerHTML = "hi there!";
		text2.style.top = 40 + 'px';
		text2.style.left = 0 + 'px';
		document.body.appendChild(text2);
		
		 
		// (4)make lights
		var light = new THREE.DirectionalLight(0xcccccc);
		light.position = new THREE.Vector3(0.577, 0.577, 1000);
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
	
	// staticに描画するだけの関数
	function render() {
	   	requestAnimationFrame(render);
	   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	    renderer.render(scene, scene.camera);
	};
	
	// マウスイベント関連
	var mouseDown = false;
	document.body.addEventListener("mousedown", function(event) {
	    mouseDown = true;
	}, false);
	document.body.addEventListener("mouseup", function(event) {
	    mouseDown = false;
	}, false);
	function onDocumentMouseClick(event) {
		if (selectedModelLoaded) {
			var newMesh = new THREE.Mesh( selectedModelMesh.geometry,
					new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ));
			
			newMesh.scale = new THREE.Vector3(10, 10, 10);
			newMesh.position = new THREE.Vector3(
				Math.random () * 100, Math.random () * 100, Math.random () * 100);
			//scene.scene.add(selectedModelMesh);
			scene.scene.add(newMesh);
			
		    console.log(newMesh);
		    getModelTransforms();
	   }
	}
	function getModelTransforms() {
		var array = [], i;
		//for (var m in scene.scene.children) {// 全てstring
		//for (var m in scene.objects) {
		for (i = 0; i < scene.scene.children.length; i++) {
			console.log(typeof(scene.scene.children[i]));
			//console.log(scene.scene.children[i]);
			if (i==0) {
				continue;// stageだから
			}
			
			if (scene.scene.children[i] instanceof THREE.Mesh) {
			//if (typeof(scene.scene.children[i]) == THREE.Mesh) {
				console.log(scene.scene.children[i]);
				//var array = [];
				var s = JSON.stringify(scene.scene.children[i].position.toArray());
				array.push(s);
			}
		}
	
		return array;
	}
	function send(event) {
		console.log(scene.objects);
		console.log(scene.scene.children);
		console.log("begin ajax request.");
		$.ajax({
	      url: 'ready',
	      type: 'POST',
	      data: {
	        code: getModelTransforms()
	        //code: "data from javascript."
	      },
	      success: function(data, event, status, xhr) {
	      	console.log("request succeed.");
	      },
	      error: function(event, data, status, xhr) {
	        console.log("request failed.");
	      }
	    });
	}
	function insertTransforms(event) {
		console.log("inserting transforms to form.");
		//console.log(model_json);
		//console.log(JSON.stringify(model_json));
		
		var positions = getModelTransforms();
		console.log(positions);
		console.log(JSON.stringify(positions));
		$(document).ready(function(){
			$("#transforms_field").val(JSON.stringify(positions));
			//$("#stage_field").val(JSON.stringify(model_json));
		});
	}
	
	// meshを動かした後renderする関数
	function animate() {    
	    /*spdy =  (screenH / 2 - mouseY) / 40;
	    spdx =  (screenW / 2 - mouseX) / 40;
	    
	    if (mouseDown){
	        mesh.rotation.x = spdy;
	        mesh.rotation.y = spdx;
	        //console.log("spdy:" + spdy);
	    }*/
		
		//scene.camera.lookAt(new THREE.Vector3(scene.camera.position.x + 1000,
		//	scene.camera.position.y + 1000, 50));
	    requestAnimationFrame( animate );
	    
	    /*scene.camera.position.x += ( mouseX - scene.camera.position.x ) * 0.05;
		scene.camera.position.y += ( - mouseY - scene.camera.position.y ) * 0.05;
		scene.camera.lookAt( scene.scene.position );*/
	    renderer.render(scene.scene, scene.camera);
	    
	     // 更新処理
	    stats.update();
	    controls.update();
		text2.innerHTML = "" + scene.camera.position.x.toString() + " "
			+ scene.camera.position.y.toString() + " " + scene.camera.position.z.toString();
	}
	function onDocumentMouseWheel( event ) {
	    fov -= event.wheelDeltaY * 0.05;
	    //scene.camera.projectionMatrix = THREE.Matrix4.makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );
	    //scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );//15, 500 / 500
	    scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 );
	}
)};
