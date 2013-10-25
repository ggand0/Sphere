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
    @textures = @model_datum.textures[0]
    if !@model_datum.textures.empty?
      p(@model_datum.textures)
      p("debug texture url:")
      p(@textures.data.url)
    end

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
    #@model_datum = ModelDatum.new(model_datum_params)
    
    # フォームからファイルを受取り、my_dataフォルダ内に一時保存、
    # JSONファイルにコンバートした後、文字列を抜き出してDBに保存する。
    # ToDo:主要な処理をServiceオブジェクトへ移動する
    
    
    # アップロードされたファイルをmodel/my_dataに一時的に保存する
    file = params['model_datum']['file']# 指定されたファイルにアクセス
    defPath = "/var/www/html/RailsTest/model/my_data/"
    p(defPath + file.original_filename)
    
    of = File.open(defPath + file.original_filename, 'w')
    of.write(file.read)
    of.close
    
    # JSON形式に変換
    p("json export result : ")
    value = %x(python2.6 my_data/convert_to_threejs.py my_data/#{file.original_filename} my_data/#{file.original_filename}.js 2>&1)
    p(value)
    
    # 元ファイル削除
    p("deleting org file...")
    value = %x(rm -f #{defPath}#{file.original_filename})
    p(value)
    
    # DBに文字列としてJSONファイルの内容を格納（JSONファイルに変換した後であることをよく確認）
    #file = open(defPath + params[:model_datum][:fileName])#old
    jsfile = open(defPath + file.original_filename + ".js")
    @jsonstring = ""
    while line = jsfile.gets
      @jsonstring += line
    end
    
    @model_datum = ModelDatum.new(:modeldata => @jsonstring, :fileName => params[:model_datum][:fileName])
    
    p("form data:")
    p(params[:model_datum][:texture])
      
    if params[:model_datum][:texture] != nil
      #@textures = Texture.new(:data => params.require(:model_datum).permit(:texture))
      #@textures = Texture.new(:data => params[:file])# みたいな形式でいいらしい
      #@textures = Texture.new(:data => params[:model_datum][:texture])
      #Paperclip::AdapterRegistry::NoHandlerError in ModelDataController#create
      @textures = Texture.new(:data => params[:model_datum][:texture]['data'])
      
      #@model_datum.textures.build
      @model_datum.textures << @textures
      p("variable @model_datum : ")
      #p(params[:model_datum][:texture])#in
      p(@model_datum.textures)
    end
    
    # saveしてDBへ保存
    respond_to do |format|
      #if @model_datum.save && @textures.save
      if @model_datum.save
        format.html { redirect_to @model_datum, notice: 'Model datum was successfully created.' }
        format.json { render action: 'show', status: :created, location: @model_datum }
      else
        format.html { render action: 'new' }
        format.json { render json: @model_datum.errors, status: :unprocessable_entity }
      end
    end
    
    # JSON(.js)ファイル削除
    p(file)
    p(file.original_filename+".js")
    value = %x(rm -f #{defPath}#{file.original_filename}.js)
    p("deleting .js file...")
    p(value)
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
