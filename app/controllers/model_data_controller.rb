#-*- coding: utf-8 -*-
class ModelDataController < ApplicationController
  before_action :set_model_datum, only: [:show, :edit, :update, :destroy]

  # GET /model_data
  # GET /model_data.json
  def index
    @model_data = ModelDatum.all

=begin
    #debug
    defPath = "/var/www/html/RailsTest/model/my_data/"
    filename = "monkey_notexture.fbx.js"
    sig = ".js"
    #value = %x(ls)
    value = %x(rm #{defPath}#{filename}  2>&1)
    p("removing files debug")
    p(value)
    render :text => value
=end
  end

  # GET /model_data/1
  # GET /model_data/1.json
  def show
    @textures = @model_datum.textures
  end

  # GET /model_data/new
  def new
    @model_datum = ModelDatum.new
    @textures = Texture.new
  end

  # GET /model_data/1/edit
  def edit
  end
  
  # POST /model_data
  # POST /model_data.json
  def create
    # フォームからファイルを受取り、my_dataフォルダ内に一時保存、
    # JSONファイルにコンバートした後、文字列を抜き出してDBに保存する。
    # ToDo:主要な処理をServiceオブジェクトへ移動する
    
    
    # アップロードされたファイルをmodel/my_dataに一時的に保存する
    file = params['model_datum']['file']
    python_path = CONFIG['python_path']
    tmp_path = CONFIG['tmp_file_path']
    script_path = CONFIG['script_path']

    # tmp file作成
    require 'tempfile'
    file_name = ('a'...'z').to_a.shuffle.join()
    temp = Tempfile::new(file_name, tmp_path)
    temp << file.read
    
    # JSON形式に変換
    # テクスチャurlにmy_data/を含めたくないので、ディレクトリ移動後に実行
    value = %x(cd #{tmp_path}; #{python_path} #{script_path} #{temp.path} #{temp.path}.js 2>&1)
    p("JSON export result : ")
    p(value)
    
    # DBに文字列としてJSONファイルの内容を格納
    jsfile = open(temp.path + ".js")
    @jsonstring = ""
    while line = jsfile.gets
      @jsonstring += line
    end

    @model_datum = ModelDatum.new(:modeldata => @jsonstring, :title => params[:model_datum][:title])
    if params[:model_datum][:texture] != nil
      for file in params[:model_datum][:texture][:model_datum][:textures]
        texture = Texture.new(:data => file)
        @model_datum.textures << texture
      end
    end
    
    # saveしてDBへ保存
    respond_to do |format|
      if @model_datum.save!
        format.html { redirect_to @model_datum, notice: 'Model datum was successfully created.' }
        format.json { render action: 'show', status: :created, location: @model_datum }
      else
        format.html { render action: 'new' }
        format.json { render json: @model_datum.errors, status: :unprocessable_entity }
      end
    end
    
    # JSON(.js)ファイル削除
    p("Deleting .js file...")
    value = %x(rm -f #{jsfile.path})
    p(value)
    temp.close(true)
  end

  # PATCH/PUT /model_data/1
  # PATCH/PUT /model_data/1.json
  def update
    respond_to do |format|
      if @model_datum.update(model_datum_params)
        format.html { redirect_to @model_datum, notice: 'Model datum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @model_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /model_data/1
  # DELETE /model_data/1.json
  def destroy
    @model_datum.destroy
    respond_to do |format|
      format.html { redirect_to model_data_url }
      format.json { head :no_content }
    end
  end
  
  def runPython

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model_datum
      @model_datum = ModelDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def model_datum_params
      #params.permit(:model_datum)
      params.require(:model_datum).permit(:modeldata, :texture, :textures)
      #params.require(:model_datum).permit(:modeldata, :model_datum_id)
    end
    
    def textures_params
      params.require(:textures).permit(:data)
    end
end
