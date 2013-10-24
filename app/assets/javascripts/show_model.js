var fileName = "";
//var model_json = 
var obj;

var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 1000);

var renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

var loader = new THREE.JSONLoader();
//loader.load( "my_data/testFbx.js", modelToScene );
//loader.load( "/var/www/html/RailsTest/model/my_data/testFbx.js", modelToScene );
console.log(model_json);
//loader.load( model_json, modelToScene );
// 直接jsonオブジェクトから読み取る時はparseを使えばよい？
var geometry = loader.parse(lh_model);


var ambientLight = new THREE.AmbientLight(0x111111);
scene.add(ambientLight);

var light = new THREE.PointLight( 0xFFFFDD );
light.position.set( -15, 10, 15 );
scene.add( light );

function modelToScene( geometry, materials ) {
    var material = new THREE.MeshFaceMaterial( materials );
    obj = new THREE.Mesh( geometry, material );
    obj.scale.set(1,1,1);
    scene.add( obj );

}

camera.position.z = 5;
camera.position.y = 1;

var render = function () {
    requestAnimationFrame(render);

    obj.rotation.y += 0.01;
    obj.rotation.x += 0.02;

    renderer.render(scene, camera);
};

render();