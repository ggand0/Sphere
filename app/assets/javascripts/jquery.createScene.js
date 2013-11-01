// 一部の関数をJqueryプラグイン化してまとめるテスト(現在show_model.jsだけに適用)

;(function($) {
	console.log("test");
	$.fn.test = function() {
		console.log("plugin function is called.");
	};
	
	// sceneの初期設定を行う（camera, lightなど）
	$.fn.createScene = function(scene, mesh) {
		// make cameras
		var camera = new THREE.PerspectiveCamera(15, 500 / 500);
		camera.position = new THREE.Vector3(0, 0, 8);
		camera.lookAt(new THREE.Vector3(0, 0, 0));
		scene.camera = camera;
		

		// make lights
		var light = new THREE.DirectionalLight(0xcccccc);
		light.position = new THREE.Vector3(0.577, 0.577, 0.577);
		//scene.scene.add(light);
		var ambient = new THREE.AmbientLight(0x333333);
		//scene.scene.add(ambient);
	};
	
})(jQuery);
