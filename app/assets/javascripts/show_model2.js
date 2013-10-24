window.onload = function() {
	console.log("function loaded.");
	console.log(model_json);
	console.log(model_json["defaults"]);
	var loader = new THREE.SceneLoader();
	//loader.parse(model_json, function(result){ console.log(result); scene = result;}, '');
	loader.parse(model_json, createScene, '');
};

THREE.ImageUtils.crossOrigin = "";

var renderer = new THREE.WebGLRenderer({ antialias:true });
renderer.setSize(500, 500);
renderer.setClearColorHex(0x000000, 1);
document.body.appendChild(renderer.domElement);
var mesh;
var scene;
// FPS表示を格納する変数
var stats;
var isMouseDown = false;
var projector = new THREE.Projector();
var fov = 70;
function createScene(result) {
	// (1)レンダラの初期化
	/*var renderer = new THREE.WebGLRenderer({ antialias:true });
	renderer.setSize(500, 500);
	renderer.setClearColorHex(0x000000, 1);
	document.body.appendChild(renderer.domElement);*/
	// set stats
    // 右上に表示するようCSSを記述してbody直下に表示
    stats = new Stats();
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.top = '0px';
    stats.domElement.style.left= '500px';
    stats.domElement.style.zIndex = 100;
    document.body.appendChild(stats.domElement);
	 
	// (2)シーンの作成
	//var scene = new THREE.Scene();
	//var loader = new THREE.SceneLoader();
	//loader.parse(model_json, function(result){scene = result;}, '');
	console.log(result);
	scene = result;
	      
	 
	// (3)カメラの作成
	var camera = new THREE.PerspectiveCamera(15, 500 / 500);
	camera.position = new THREE.Vector3(0, 0, 8);
	camera.lookAt(new THREE.Vector3(0, 0, 0));
	//scene.add(camera);
	//result.camera = camera;
	scene.camera = camera;
	window.addEventListener('DOMMouseScroll', onDocumentMouseWheel, false);
  	window.addEventListener('mousewheel', onDocumentMouseWheel, false);

	 
	// (4)ライトの作成
	var light = new THREE.DirectionalLight(0xcccccc);
	light.position = new THREE.Vector3(0.577, 0.577, 0.577);
	//scene.add(light);
	 
	var ambient = new THREE.AmbientLight(0x333333);
	//scene.add(ambient);
	 
	// (5)表示する物体の作成
	//var loader = new THREE.JSONLoader();
	// see http://stackoverflow.com/questions/17182533/threejs-fbx-convertor-r58-cannot-work-with-jsonloader?answertab=active#tab-top
	  
	  
	  
	//var geometry = new THREE.SphereGeometry(1, 32, 16);
	console.log(model_json);
	//var model = loader.parse(model_json);// jsonでgeometryとmaterialが返ってくる
	//loader.parse(model_json, function(result){ console.log("result = "); console.log(result); }, '');
	  
	  
	// old:
	//var geometry = model['geometry'];
	//var material = model['materials'];
	/*var material = new THREE.MeshPhongMaterial({
	color: 0xffffff, ambient: 0xffffff,
	specular: 0xcccccc, shininess:50, metal:true,
	map: THREE.ImageUtils.loadTexture('images/1_earth_8k.jpg') });*/
	// 参考になるかも？：http://tp69.wordpress.com/2013/06/17/cors-bypass/
	//var mesh = new THREE.Mesh(model.geometry, model.material);
	/*var mesh = new THREE.Mesh(model.geometry, new THREE.MeshBasicMaterial());
	scene.add(mesh);*/
	 
	// (6)レンダリング
	var baseTime = +new Date;
	  
	//render(scene.geometries[0], result.materials[0]);
	console.log("scene:");
	console.log(scene);
	//mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
	mesh = scene.scene.children[0];
	scene.scene.children.splice(0, 1);
	scene.scene.add(mesh);
	
	
	//render();
	animate();
}
function render() {
	//console.log(result);
    /*requestAnimationFrame(render);
    mesh.rotation.y = 0.3 * (+new Date - baseTime) / 1000;
    renderer.render(scene, camera);*/
   	requestAnimationFrame(render);
   	//mesh = new THREE.Mesh(result.geometries[0], result.materials[0]);
   	//mesh = new THREE.Mesh(g, m);
   	mesh = new THREE.Mesh(scene.geometries[0], scene.materials[0]);
   	
    //mesh.rotation.y = 0.3 * (+new Date - baseTime) / 1000;
    
    
    //renderer.render(result.scene, result.camera);
    renderer.render(scene, scene.camera);
    //animate();
};

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
    // レンダリングするたびにFPSを計測
    stats.update();
}
function onDocumentMouseWheel( event ) {
    fov -= event.wheelDeltaY * 0.05;
    //scene.camera.projectionMatrix = THREE.Matrix4.makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );
    //scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, window.innerWidth / window.innerHeight, 1, 1100 );//15, 500 / 500
    scene.camera.projectionMatrix = (new THREE.Matrix4()).makePerspective( fov, 500 / 500, 1, 1100 );
}