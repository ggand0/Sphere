//window.texture_path = "textures/terrain/backgrounddetailed6.jpg";
window.onload = function() {
	console.log("function loaded.");
	console.log("model_json variable:");
	console.log(model_json);
	console.log("texture_path variable:\n" + texture_path);
	var loader = new THREE.SceneLoader();
	loader.parse(model_json, createScene, texture_path);
    //loader.load("terrain0.json", createScene);
};

THREE.ImageUtils.crossOrigin = "";

var renderer = new THREE.WebGLRenderer({ antialias:true });
renderer.setSize(500, 500);
renderer.setClearColorHex(0x000000, 1);
//document.body.appendChild(renderer.domElement);
// divに追加しておく
container = document.getElementById( 'left-box' );
container.appendChild(renderer.domElement);

var mesh;
var scene;
var stats;
var isMouseDown = false;
var fov = 70;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;
var controls;
var text2;

function createScene(result) {
	console.log("callback function called");
	
	// set stats
    stats = new Stats();
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.top = '0px';
    stats.domElement.style.left= '500px';
    stats.domElement.style.zIndex = 100;
    document.body.appendChild(stats.domElement);
	 
	// (2)create scene
	//var scene = new THREE.Scene();
	//var loader = new THREE.SceneLoader();
	//loader.parse(model_json, function(result){scene = result;}, '');
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
	controls.center = lookAtPos;
	
	//camera.lookAt(scene.scene.position);
	scene.camera = camera;
	// CONTROLS
	//controls = new THREE.OrbitControls( camera, renderer.domElement );
	
	
	/*window.addEventListener('DOMMouseScroll', onDocumentMouseWheel, false);
  	window.addEventListener('mousewheel', onDocumentMouseWheel, false);*/
	//document.addEventListener( 'mousemove', onDocumentMouseMove, false );
	
	
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
	light.position = new THREE.Vector3(0.577, 0.577, 0.577);
	//scene.add(light);
	var ambient = new THREE.AmbientLight(0x333333);
	//scene.add(ambient);
	 
	 
	// (6)rendering
	var baseTime = +new Date;
	//render(scene.geometries[0], result.materials[0]);
	console.log("scene:" + scene);
	//mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	
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
	//mesh.rotation.y = 0.3 * (+new Date - baseTime) / 1000;
   	requestAnimationFrame(render);
   	//mesh = new THREE.Mesh(result.geometries[0], result.materials[0]);
   	//mesh = new THREE.Mesh(g, m);
   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
    
    //renderer.render(result.scene, result.camera);
    renderer.render(scene, scene.camera);
};

// マウス操作関連
/*var screenW = window.innerWidth;
var screenH = window.innerHeight; 
var spdx = 0, spdy = 0, mouseX = 0, mouseY = 0, mouseDown = false;
document.addEventListener('mousemove', function(event) {
    mouseX = event.clientX;
    mouseY = event.clientY;
}, false);
document.body.addEventListener("mousedown", function(event) {
    mouseDown = true
}, false);
document.body.addEventListener("mouseup", function(event) {
    mouseDown = false
}, false);
function onDocumentMouseMove(event) {
	mouseX = event.clientX - windowHalfX;
	mouseY = event.clientY - windowHalfY;
}*/


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