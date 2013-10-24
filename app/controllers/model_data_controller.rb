class ModelDataController < ApplicationController
  before_action :set_model_datum, only: [:show, :edit, :update, :destroy]

  # GET /model_data
  # GET /model_data.json
  def index
    @model_data = ModelDatum.all
    p(@model_data)
    #@model_data = ModelDatum.find params[:title]
    #titleだけshowしたい...viewを変えれば良い？
    
    # pythonスクリプトを呼ぶテスト
    #value = %x( python --version )
    #value = %x(python --version 2>&1)
    #value = %x(python /../../my_data/hello.py 2>&1)
    pass = "/var/www/html/RailsTest/model/my_data/hello.py";
    #value = %x(python /var/www/html/RailsTest/model/my_data/hello.py 2>&1)
    #value = %x(python2.6 /var/www/html/RailsTest/model/my_data/convert_to_threejs.py /var/www/html/RailsTest/model/my_data/teapot.fbx /var/www/html/RailsTest/model/my_data/testFbx.js 2>&1)
    
    #value = %x(python2.6 /var/www/html/RailsTest/model/my_data/convert_to_threejs.py /var/www/html/RailsTest/model/my_data/fighter0.fbx /var/www/html/RailsTest/model/my_data/testFbx.js 2>&1)
    #value = %x(python /var/www/html/RailsTest/model/my_data/convert_obj_three.py -i /var/www/html/RailsTest/model/my_data/crystal0.obj -o /var/www/html/RailsTest/model/my_data/test.js 2>&1)
    
    #value = %x(python2.6 /var/www/html/RailsTest/model/my_data/convert_to_threejs.py /var/www/html/RailsTest/model/my_data/notexture.fbx /var/www/html/RailsTest/model/my_data/notexture.js 2>&1)# -c
    #render :text => value
  end

  # GET /model_data/1
  # GET /model_data/1.json
  def show
    p("debug model_datum:")
    #p(@model_datum)
    p(@model_datum.fileName)
  end

  # GET /model_data/new
  def new
    @model_datum = ModelDatum.new
  end

  # GET /model_data/1/edit
  def edit
  end
  
  # POST /model_data
  # POST /model_data.json
  def create
    #@model_datum = ModelDatum.new(model_datum_params)
    # とりあえず、model_datum_paramsをファイル名だと解釈して、同名のmy_data内の
    # jsonファイルから文字列を抜き出してDBに保存する形にする
    
    
    #file = open(model_datum_params)
    #p(model_datum_params)
    #p(params[:modeldata])
=begin
    p("params debug: fileName:")
    p(params[:model_datum].permit(:fileName, :modeldata))
    p(params[:model_datum][:fileName])
=end
    
    # ファイルをアップロードしてmodel/my_dataに一時的に保存する
    #p(params[:model_datum][:attachment])#nil
    #p(params['upload_file']['file'])
    p(params['model_datum']['file'])
    
    #file = params[:model_datum][:attachment]# 指定されたファイルにアクセス
    file = params['model_datum']['file']
    defPath = "/var/www/html/RailsTest/model/my_data/"
    p(defPath + file.original_filename)
    
    of = File.open(defPath + file.original_filename, 'w')
    of.write(file.read)
    of.close
    
    # Json形式に変換
    #value = %x("python2.6 " + defPath + "convert_to_threejs.py " + defPath + "notexture.fbx " + defPath + "notexture.js" 2>&1)
    #value = %x("python2.6 " + defPath + "convert_to_threejs.py " + defPath + file.original_filename + " " + defPath + "file.original_filename" + ".js" 2>&1)
    #value = %x("python2.6" + defPath + "convert_to_threejs.py " + defPath + file.original_filename + " " + defPath + file.original_filename + ".js" 2>&1)
    #value = %x("python2.6" + defPath + "convert_to_threejs.py" + defPath + file.original_filename + defPath + file.original_filename + ".js" 2>&1)
    
    p("json export result : ")
    #value = %x("python2.6 #{defPath}convert_to_threejs.py #{defPath}#{file.original_filename} #{defPath}#{file.original_filename}.js" 2>&1)
    #value = %x("python2.6 #{defPath}convert_to_threejs.py #{defPath}notexture.fbx #{defPath}#{file.original_filename}.js")
    #value = %x("python2.6 #{defPath}convert_to_threejs.py #{defPath}#{file.original_filename} #{defPath}#{file.original_filename}.js")
    value = %x(python2.6 my_data/convert_to_threejs.py my_data/#{file.original_filename} my_data/#{file.original_filename}.js 2>&1)
    #value = %x(python2.6 --version 2>&1)
    #value = %x(ls 2>&1)#modelにいるらしい
    
    #system("python2.6", $defPath+"convert_to_threejs.py", $defPath+$file.original_filename, $defPath+$file.original_filename+".js")
    p(value)
    #render :text => value
    
    # orgファイル削除
    p("deleting org file...")
    #value = %x("rm -f " + defPath + file.original_filename)
    value = %x("rm -f #{defPath}#{file.original_filename})
    
    p(value)
    
    # DBに文字列としてjsonファイルの内容を格納（jsonファイルに変換した後であることをmake sure）
    #file = open(defPath + params[:model_datum][:fileName])#old
    file = open(defPath + file.original_filename + ".js")
    @jsonstring = ""
    while line = file.gets
      @jsonstring += line
    end
    
    @model_datum = ModelDatum.new(:modeldata => @jsonstring, :fileName => params[:model_datum][:fileName])
    p("variable @model_datum : ")
    p(@model_datum.fileName)
    # texture
    p("image debug")
    p(params['model_datum']['data'])
    p(@model_datum.textures)
    #p(@model_datum.textures.model_datum_id)
    #p(@model_datum.textures.modeldata_id)
    #@textures = Texture.new(:id => '0', :data => :params[:model_datum][:data])
    #@textures = Texture.new(:data => ['model_datum']['data'])
          
    #@textures = Texture.new(@model_datum.id)
    @textures = @model_datum.textures.build

    respond_to do |format|
      if @model_datum.save && @textures.save
        format.html { redirect_to @model_datum, notice: 'Model datum was successfully created.' }
        format.json { render action: 'show', status: :created, location: @model_datum }
      else
        format.html { render action: 'new' }
        format.json { render json: @model_datum.errors, status: :unprocessable_entity }
      end
    end
    
    # json(.js)ファイル削除
    value = %x("rm -f " + defPath + file.original_filename + ".js")
    p("deleting .js file...")
    p(value)
    
    p("image debug2")
    p(params['model_datum']['data'])
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
      params.require(:model_datum).permit(:modeldata)
      #params.require(:model_datum).permit(:modeldata, :model_datum_id)
    end
    
    #def textures_params
    #  params.require(:textures).permit(:model_datum_id, :model_data_id, :modeldata_id)
    #end
end
