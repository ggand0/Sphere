$(function() {
	THREE.ImageUtils.crossOrigin = "";

	var canvasSize = new THREE.Vector2(1024, 768);
	var renderer = new THREE.WebGLRenderer({ antialias:true });
	renderer.setSize(canvasSize.x , canvasSize.y);
	renderer.setClearColorHex(0x000000, 1);
	
	//var container = $("#left-box")[0];
	//container.appendChild(renderer.domElement);
	var $container = $("#left-box");
	var $renderer = $(renderer.domElement);
	$container.append($renderer);

	var mesh, scene, stats, controls;
	var selectedModelMesh;
	var selectedModelLoaded = false;
	var isMouseDown = false;
	var fov = 70;
	var $debugText;
	
	// カメラ関係
	var ray, mouse3D;
	var projector = new THREE.Projector();
	var onMouseDownPosition = new THREE.Vector2();
	var onMouseDownPhi = 60;
	var onMouseDownTheta = 45;
	var radious = 1000;
	var theta = 45;
	var phi = 60;
	
	init();
	
	
	
	function init() {
		console.log("function loaded.");
		console.log("modelJSON variable:");
		console.log(modelJSON);
		console.log("texturePath variable:\n" + texturePath);
		var loader = new THREE.SceneLoader();
		loader.parse(modelJSON, createScene, texturePath);
		
		// sceneが格納されるより先に実行されてしまうのでcreateScene内で実行する
		//loader.parse(selectedModel, callBack, '');
	}
	function callBack(result) {
		console.log("model callback function called.");
	
		selectedModelMesh = result.scene.children[0];
		selectedModelLoaded = true;
	
		console.log("positions:");
		console.log(modelTransforms);
	
		// Convert JSON to array
		var positions = [];
		$.each(modelTransforms, function(i, obj) {
			//console.log(obj);
			positions.push(JSON.parse(obj));
		});
		console.log(positions);
	
		// modelTransformsで与えられる位置に配置する		
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
		// create scene
		console.log(result);
		scene = result;
		
		// Modelのparse開始
		var loader = new THREE.SceneLoader();
		loader.parse(selectedModel, callBack, '');
		
		
		// set stats
	    stats = new Stats();
	    stats.domElement.style.position = 'absolute';
	    stats.domElement.style.top = '0px';
	    stats.domElement.style.left= '500px';
	    stats.domElement.style.zIndex = 100;
	    $('body').append(stats.domElement);

		// make cameras
		var camera = new THREE.PerspectiveCamera(15, canvasSize.x / canvasSize.y, 10, 100000);
		var lookAtPos = new THREE.Vector3(camera.position.x + 1000,
			camera.position.y + 1000, 50);
		//camera.position.set(0, 200, 0);
		camera.position.x = radious * Math.sin( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 );
		camera.position.y = radious * Math.sin( phi * Math.PI / 360 );
		camera.position.z = radious * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 );
		ray = new THREE.Ray(camera.position, null);
		scene.camera = camera;
		
		// old try
		//controls = new THREE.EditorControls( camera, renderer.domElement ); 
		/*controls = new THREE.TrackballControls( camera, renderer.domElement );
		controls.rotateSpeed = 5.0;
		controls.zoomSpeed = 1.2;
		controls.panSpeed = 0.8;
		controls.noZoom = false;
		controls.noPan = false;
		controls.staticMoving = true;
		controls.dynamicDampingFactor = 0.3;*/
		//controls.center = lookAtPos;	// lookAtPosは変わるが回転中心も変わる
		//camera.lookAt(scene.scene.position);
		
	
		// make lights
		var light = new THREE.DirectionalLight(0xcccccc);
		light.position = new THREE.Vector3(0.577, 0.577, 1000);
		scene.scene.add(light);
		var ambient = new THREE.AmbientLight(0x333333);
		scene.scene.add(ambient);
		
		// draw debug info
		$debugText = $('<div>');
		$debugText.addClass('debugText');
		$debugText.text("camera position:");
		$('body').append($debugText);
		
		// 変数として持ちたいのでsceneから読み込んだ後再び追加
		mesh = scene.scene.children[0];
		scene.scene.children.splice(0, 1);
		scene.scene.add(mesh);
		
		// y軸を上にしたいので回転させる
		for (i=0; i < scene.scene.children.length; i++) {
			console.log(scene.scene.children[i].rotation);
			console.log(scene.scene.children[i].rotation.y);
			//scene.scene.children[i].rotation.y = -90 * Math.PI / 180;
			scene.scene.children[i].rotation.x = -90 * Math.PI / 180;
		}
		
		// 描画
		animate();
		
	}
	
	
	// マウスイベント追加
	$(document).on("mousedown", function(event) {
	    isMouseDown = true;
	    
	    onMouseDownTheta = theta;
		onMouseDownPhi = phi;
		onMouseDownPosition.x = event.originalEvent.clientX;
		onMouseDownPosition.y = event.originalEvent.clientY;
		
		//animate();
		scene.camera.lookAt(new THREE.Vector3(0, 0, 0));
	});
	$(document).on("mouseup", function(event) {
	    isMouseDown = false;
	    
	    onMouseDownPosition.x = event.originalEvent.clientX - onMouseDownPosition.x;
		onMouseDownPosition.y = event.originalEvent.clientY - onMouseDownPosition.y;
		
		if ( onMouseDownPosition.length() > 5 ) {
			return;
		}
		//animate();
		scene.camera.lookAt(new THREE.Vector3(0, 0, 0));
	});
	$(document).on("mousemove", function(event) {
		event.preventDefault();

	    if ( isMouseDown ) {
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
	    }
	
	    mouse3D = projector.unprojectVector(
	        new THREE.Vector3(
	            ( event.originalEvent.clientX / renderer.domElement.width ) * 2 - 1,
	            - ( event.originalEvent.clientY / renderer.domElement.height ) * 2 + 1,
	            0.5
	        ),
	        scene.camera
	    );
	    //ray.direction = mouse3D.subSelf( scene.camera.position ).normalize();
	    ray.direction = mouse3D.sub( scene.camera.position ).normalize();
	    
	    //render();
	    scene.camera.lookAt(new THREE.Vector3(0, 0, 0));
	});
	$(document).on("mousewheel", function(event) {
		/*fov -= event.wheelDeltaY * 0.05;
	    scene.camera.projectionMatrix = (
	    	new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 );*/
		radious -= event.originalEvent.wheelDeltaY;

		scene.camera.position.x = radious * Math.sin( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 );
		scene.camera.position.y = radious * Math.sin( phi * Math.PI / 360 );
		scene.camera.position.z = radious * Math.cos( theta * Math.PI / 360 ) * Math.cos( phi * Math.PI / 360 );
		scene.camera.updateMatrix();
	});
	
	// モデル位置取得関連
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
	

	// 描画関連
	function render() {
	   	requestAnimationFrame(render);
	    renderer.render(scene, scene.camera);
	};
	// meshを動かした後renderする関数
	function animate() {    
	    requestAnimationFrame( animate );
	    renderer.render(scene.scene, scene.camera);
	    
	     // 更新処理
	    stats.update();
	    //controls.update();
		$debugText.text("" + scene.camera.position.x.toString() + " "
			+ scene.camera.position.y.toString() + " "
			+ scene.camera.position.z.toString());
	}
});
