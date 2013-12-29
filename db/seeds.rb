# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

include ActionDispatch::TestProcess
require "#{Rails.root}/app/controllers/model_data_service"

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
      data: fixture_file_upload('spec/fixtures/files/backgrounddetailed6.jpg', 'image/png')
    }
  }
}

file = params[:stage][:file]
jsonstring = file.read
stage = Stage.new(scene_data: jsonstring, title: params[:stage][:title])
unless params[:stage][:texture].nil?
  textures = Texture.new(data: params[:stage][:texture][:data])#'data'
  stage.textures << textures
end
stage.save!
