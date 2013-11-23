#-*- coding: utf-8 -*-
class ModelDataController < ApplicationController
  before_action :set_model_datum, only: [:show, :edit, :update, :destroy]

  # GET /model_data
  # GET /model_data.json
  def index
    @model_data = ModelDatum.all
  end

  # GET /model_data/1
  # GET /model_data/1.json
  def show
    @data = ActiveSupport::JSON.decode(@model_datum.modeldata)
    @textures = @model_datum.textures
    unless @model_datum.textures.nil?
      @urls = []
      for texture in @model_datum.textures
        @urls << texture.data.url
      end
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
  # フォームからファイルを受取り、my_dataフォルダ内に一時保存、
  # JSONファイルにコンバートした後、文字列を抜き出してDBに保存する。
  def create
    # コンバート&モデル作成
    converter = ModelDataService.new()
    @model_datum = converter.convert_model_datum(params)
    
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
      params.require(:model_datum).permit(:modeldata, :texture, :textures)
    end
    
    def textures_params
      params.require(:textures).permit(:data)
    end
end
