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
		console.log("function loaded.");
		console.log("model_json variable:");
		console.log(model_json);
		console.log("texture_path variable:\n" + texture_path);
		var loader = new THREE.SceneLoader();
		loader.parse(model_json, createScene, texture_path);
		
		// sceneが格納されるより先に実行されてしまうのでcreateScene内で実行する
		//loader.parse(selected_model, callBack, '');
	}
	function callBack(result) {
		console.log("model callback function called.");
	
		selectedModelMesh = result.scene.children[0];
		selectedModelLoaded = true;
	
		console.log("positions:");
		console.log(model_transforms);
	
		// Convert JSON to array
		var positions = [];
		$.each(model_transforms, function(i, obj) {
			//console.log(obj);
			positions.push(JSON.parse(obj));
		});
		console.log(positions);
	
		// model_transformsで与えられる位置に配置する		
		var i;
		for (i=0; i < positions.length; i++) {
			var newMesh = new THREE.Mesh( selectedModelMesh.geometry,
				new THREE.MeshLambertMaterial( { color: Math.random() * 0xffffff } ));
			newMesh.scale = new THREE.Vector3(10, 10, 10);
			
			//console.log(positions[i]);
			var pos = new THREE.Vector3().fromArray(positions[i]);
			console.log(pos);
			newMesh.position = pos;
			
			scene.scene.add(newMesh);
		}
		console.log(scene);
	}
	function createScene(result) {
		console.log("callback function called.");
		// (2)create scene
		console.log(result);
		scene = result;
		// Modelのparse開始
		var loader = new THREE.SceneLoader();
		loader.parse(selected_model, callBack, '');
		
		
		
		// set stats
	    stats = new Stats();
	    stats.domElement.style.position = 'absolute';
	    stats.domElement.style.top = '0px';
	    stats.domElement.style.left= '500px';
	    stats.domElement.style.zIndex = 100;
	    //document.body.appendChild(stats.domElement);
	    $('body').append(stats.domElement);
		 
		
		 
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
	
	
		// draw debug info
		//debugText = document.createElement('div');
		$debugText = $('<div>');
		$debugText.addClass('debugText');
		$debugText.html("camera position:");
		//document.body.appendChild(text2);
		$('body').append($debugText);
		
		
		// make lights
		var light = new THREE.DirectionalLight(0xcccccc);
		light.position = new THREE.Vector3(0.577, 0.577, 1000);
		scene.scene.add(light);
		var ambient = new THREE.AmbientLight(0x333333);
		scene.scene.add(ambient);
		
		// 変数として持ちたいのでsceneから読み込んだ後再び追加
		mesh = scene.scene.children[0];
		scene.scene.children.splice(0, 1);
		scene.scene.add(mesh);
		
		// 描画
		animate();
	}
	
	// staticに描画するだけの関数
	function render() {
		//mesh.rotation.y = 0.3 * (+new Date - baseTime) / 1000;
	   	requestAnimationFrame(render);
	   	//mesh = new THREE.Mesh(result.geometries[0], result.materials[0]);
	   	//mesh = new THREE.Mesh(g, m);
	   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	    
	    //renderer.render(result.scene, result.camera);
	    renderer.render(scene, scene.camera);
	};
	// マウスイベント関連
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
	function onDocumentMouseWheel( event ) {
	    fov -= event.wheelDeltaY * 0.05;
	    //scene.camera.projectionMatrix = THREE.Matrix4.makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );
	    //scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );//15, 500 / 500
	    scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 );
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
		
		console.log(array);
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
		var positions = getModelTransforms;
		$(document).ready(function(){
			$("#transforms_field").val(positions);
		});
	}
	
	// meshを動かした後renderする関数
	function animate() {    
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
