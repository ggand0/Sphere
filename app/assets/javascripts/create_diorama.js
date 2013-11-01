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
	
	
	
	// railsで指定した、JSONが入ってるグローバル変数をSceneLoaderに投げる
	function init() {
		var loader = new THREE.SceneLoader();
		loader.parse(model_json, createScene, texture_path);
		loader.parse(selected_model, callBack, '');
	    //loader.load("terrain0.json", createScene);
	}
	// SceneLoaderが返したModelオブジェクトを変数へ入れる
	function callBack(result) {
		console.log("model callback function called.");
		// sceneで返ってくるので面倒だ
		selectedModelMesh = result.scene.children[0];
		selectedModelLoaded = true;
	}
	// SceneLoaderが返したStageオブジェクトにいろいろ追加する
	function createScene(result) {
		console.log("callback function called.");
		
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
	
	
		// add mouse click event
		//document.addEventListener('click', onDocumentMouseClick, false);
		//document.addEventListener('dblclick', insertTransforms, false);
		$('body').on('click', onDocumentMouseClick);
		$('body').on('dblclick', insertTransforms);
	
	
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
	
	// staticに描画するだけの関数[未使用]
	function render() {
	   	requestAnimationFrame(render);
	   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	    renderer.render(scene, scene.camera);
	};
	
	// マウスイベント関連
	var mouseDown = false;
	$(document).on("mousedown", function(event) {
	    mouseDown = true;
	});
	$(document).on("mouseup", function(event) {
	    mouseDown = false;
	});
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
	
	// 配置されたモデルの位置を取得しarrayに格納して返す
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
	// Railsのcontroller内のactionにデータを送るテスト
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
	// モデルの位置データをViewのフォームに入力する
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
