//window.texture_path = "textures/terrain/backgrounddetailed6.jpg";
window.onload = function() {
	console.log("function loaded.");
	console.log("model_json variable:\n" + model_json);
	console.log(model_json);
	
	var loader = new THREE.SceneLoader();
	
	var sig = "file://";
	console.log("texture_path variable:\n" + texture_path);
	console.log(sig+texture_path);
	loader.parse(model_json, createScene, texture_path);
    //loader.load("terrain0.json", createScene);
};

THREE.ImageUtils.crossOrigin = "";

var renderer = new THREE.WebGLRenderer({ antialias:true });
renderer.setSize(500, 500);
renderer.setClearColorHex(0x000000, 1);
//document.body.appendChild(renderer.domElement);
container = document.getElementById( 'left-box' );
container.appendChild(renderer.domElement);

var mesh;
var scene;
var stats;
var isMouseDown = false;
var fov = 70;

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
	var camera = new THREE.PerspectiveCamera(15, 500 / 500);
	camera.position = new THREE.Vector3(0, 0, 8);
	camera.lookAt(new THREE.Vector3(0, 0, 0));
	scene.camera = camera;
	window.addEventListener('DOMMouseScroll', onDocumentMouseWheel, false);
  	window.addEventListener('mousewheel', onDocumentMouseWheel, false);

	 
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
var screenW = window.innerWidth;
var screenH = window.innerHeight; /*SCREEN*/
var spdx = 0, spdy = 0, mouseX = 0, mouseY = 0, mouseDown = false; /*MOUSE*/
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

// meshを動かした後renderする関数
function animate() {    
    spdy =  (screenH / 2 - mouseY) / 40;
    spdx =  (screenW / 2 - mouseX) / 40;
    
    if (mouseDown){
        mesh.rotation.x = spdy;
        mesh.rotation.y = spdx;
        //console.log("spdy:" + spdy);
    }
    //render();
    requestAnimationFrame( animate );
    renderer.render(scene.scene, scene.camera);
    
    // FPS表示の更新
    stats.update();
}
function onDocumentMouseWheel( event ) {
    fov -= event.wheelDeltaY * 0.05;
    //scene.camera.projectionMatrix = THREE.Matrix4.makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );
    //scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );//15, 500 / 500
    scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 );
}