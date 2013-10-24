{
	"metadata": {
		"formatVersion" : 3.2,
		"type"		: "scene",
		"generatedBy"	: "convert-to-threejs.py",
		"objects"       : 1,
		"geometries"    : 1,
		"materials"     : 1,
		"textures"      : 1
	},

	"urlBaseType": "relativeToScene",

	"objects" :
	{
		"Cube" : {
			"geometry" : "Geometry_27_Cube",
			"material" : "Material__Checker_bmp",
			"position" : [ 0, 0, 0 ],
			"rotation" : [ 0, -0, 0 ],
			"scale"	   : [ 1, 1, 1 ],
			"visible"  : true
		}
	},

	"geometries" :
	{
		"Geometry_27_Cube" : {
			"type"  : "embedded",
			"id" : "Embed_27_Cube"
		}
	},

	"materials" :
	{
		"Material__Checker_bmp": {
			"type"    : "MeshLambertMaterial",
			"parameters"  : {
				"color"  : 13421772,
				"ambient"  : 0,
				"emissive"  : 13421772,
				"reflectivity"  : 1,
				"transparent" : false,
				"opacity" : 1.0,
				"map": "Texture_31_Checker",
				"wireframe" : false,
				"wireframeLinewidth" : 1
			}
		}
	},

	"textures" :
	{
		"Texture_31_Checker": {
			"url"    : "Checker.bmp",
			"repeat" : [ 1, 1 ],
			"offset" : [ 0, 0 ],
			"magFilter" : "LinearFilter",
			"minFilter" : "LinearMipMapLinearFilter",
			"anisotropy" : true
		}
	},

	"embeds" :
	{
		"Embed_27_Cube" : {
			"metadata"  : {
				"vertices" : 8,
				"normals" : 8,
				"colors" : 0,
				"faces" : 6,
				"uvs" : [ 4 ]
			},
			"boundingBox"  : {
				"min" : [ -1.0,-1.000001,-1.0 ],
				"max" : [ 1.0,1.0,1.0 ]
			},
			"scale" : 1,
			"materials" : [  ],
			"vertices" : [ 1,1,-1,1,-1,-1,-1,-1,-1,-1,1,-1,1,0.999999,1,0.999999,-1,1,-1,-1,1,-1,1,1 ],
			"normals" : [ 0.577349,0.577349,-0.577349,0.577349,-0.577349,-0.577349,-0.577349,-0.577349,-0.577349,-0.577349,0.577349,-0.577349,0.577349,0.577349,0.577349,0.577349,-0.577349,0.577349,-0.577349,-0.577349,0.577349,-0.577349,0.577349,0.577349 ],
			"colors" : [  ],
			"uvs" : [ [0,0,1,0,1,1,0,1] ],
			"faces" : [ 43,0,1,2,3,0,0,1,2,3,0,1,2,3,43,4,7,6,5,0,0,1,2,3,4,7,6,5,43,0,4,5,1,0,0,1,2,3,0,4,5,1,43,1,5,6,2,0,0,1,2,3,1,5,6,2,43,2,6,7,3,0,0,1,2,3,2,6,7,3,43,4,0,3,7,0,0,1,2,3,4,0,3,7 ]
		}
	},

	"fogs" :
	{
	
	},

	"transform" :
	{
		"position"  : [ 0, 0, 0 ],
		"rotation"  : [ 0, 0, 0 ],
		"scale"     : [ 1, 1, 1 ]
	},

	"defaults" :
	{
		"bgcolor" : [ 0.667, 0.667, 0.667 ],
		"bgalpha" : 1,
		"camera"  : "",
		"fog"  	  : ""
	}
}