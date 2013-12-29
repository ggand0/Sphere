# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

include ActionDispatch::TestProcess
require "#{Rails.root}/app/controllers/model_data_service"
require 'rack/test'

# ModelData
params = {
  model_datum: {
    file: fixture_file_upload('spec/fixtures/files/notexture.fbx'),
    title: 'seed data'
  }
}
converter = ModelDataService.new()
model_datum = converter.convert_model_datum(params)
model_datum.save!

# Stage
valid_file = File.new(Rails.root.join('spec', 'fixtures', 'files', 'backgrounddetailed6.jpg'))
params = {
  stage: {
    file: fixture_file_upload('spec/fixtures/files/terrain0.json'),
    texture: {
      stage: {
        textures: [fixture_file_upload('spec/fixtures/files/backgrounddetailed6.jpg', 'image/jpg')]
      }
    },
    title: 'seed data'
  }
}
puts params[:stage][:texture][:stage]

file = params[:stage][:file]
jsonstring = file.read
stage = Stage.new(scene_data: jsonstring, title: params[:stage][:title])

unless params[:stage][:texture].nil?
  params[:stage][:texture][:stage][:textures].each do |f|
    stage.textures << Texture.new(data: f)
  end
end
stage.save!
