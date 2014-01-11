#require 'app/assets/javascripts/dioramacontroller.js.coffee'
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery-fileupload/basic
#= require threejs/build/three.js

#= require application
#= require dioramacontroller
#= require dioramas
#= require dioramaview

describe "diorama controller", ->
  controller = undefined
  
  ###it "should have DioramaModel", ->
    #expect(controller.dioramaModel).toEqual(model)
    controller = new Sphere.DioramaController()
    model = new Sphere.Diorama()
    controller.dioramaModel.should.eql(model)###
