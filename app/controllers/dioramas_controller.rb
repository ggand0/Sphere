class DioramasController < ApplicationController
  before_action :set_diorama, only: [:show, :edit, :update, :destroy]
    
  DEF_STAGE_ID = 6
  DEF_MODEL_ID = 103

  # GET /dioramas
  # GET /dioramas.json
  def index
    @dioramas = Diorama.all
  end

  # GET /dioramas/1
  # GET /dioramas/1.json
  def show
    @stageTextures = @diorama.stage.textures[0]
    @selectedModel = @diorama.model_datum[0]
    
    @positions = []
    for model_transform in @diorama.model_transforms do
      if (model_transform.transform != nil)
        @positions << model_transform.transform
      end
    end
    
    @ids = []
    @modelData = []
    @textures = []
    # ひとまず使用されてるmodeldata全部突っ込む仕様で。後々重複を避けるように変更する
    for model_datum in @diorama.model_datum do
      @ids << model_datum.id
      @modelData << model_datum.modeldata
      @textures << model_datum.textures[0]
    end
  end

  # GET /dioramas/new
  def new
    @diorama = Diorama.new

    # 素材配置のために格納しておく
    @model_data = ModelDatum.all
    @stages = Stage.all
    
    # 選択しているstageとmodeldataを入れる変数
    @selectedModel = ModelDatum.find(DEF_MODEL_ID)
    @selectedStage = Stage.find(DEF_STAGE_ID)
    @selectedModelTextures = @selectedModel.textures[0]
    @selectedStageTextures = @selectedStage.textures[0]
    
    # 初期値設定
    # セッションにデフォルトで使うstage_idを入れておいてcreateする時に使う
    session[:stage_id] = DEF_STAGE_ID
    session[:model_id] = DEF_MODEL_ID
  end

  # GET /dioramas/1/edit
  def edit
  end

  # [未使用]
  def ready
    render :nothing => true
    @isReady = true

    for position in params[:code] do
      @trans = ModelTransform.new(:transform => position)
    end
  end
  
  # JS側で指定されたIDのモデルデータをセットする
  def set_model
    @diorama = Diorama.new
    @model_data = ModelDatum.all
    @stages = Stage.all
    @selectedStage = Stage.find(DEF_STAGE_ID)
    @selectedModel = ModelDatum.find(params[:id])
    @selectedStageTextures = @selectedStage.textures[0]
    @selectedModelTextures = @selectedModel.textures[0]
    session[:stage_id] = DEF_STAGE_ID
    session[:model_id] = params[:id]

    render :action => "new"
  end
  
  
  # POST /dioramas
  # POST /dioramas.json
  def create
    @diorama = Diorama.new(:title => params[:diorama][:title])

    # Stage追加
    @diorama.stage = Stage.find(session[:stage_id])

    # ModelTransforms追加
    tmp = params[:diorama][:model_transforms_attributes]['0']['transform']
    posArray = ActiveSupport::JSON.decode(tmp)
    
    for position in posArray do
      # convert array to string
      @transform = ModelTransform.new(:transform => position['pos'].to_s)
      @diorama.model_transforms << @transform
      @diorama.model_datum << ModelDatum.find(position['id'])
    end

    respond_to do |format|
      if @diorama.save!
        format.html { redirect_to @diorama, notice: 'Diorama was successfully created.' }
        format.json { render action: 'show', status: :created, location: @diorama }
      else
        format.html { render action: 'new' }
        format.json { render json: @diorama.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dioramas/1
  # PATCH/PUT /dioramas/1.json
  def update
    respond_to do |format|
      if @diorama.update(diorama_params)
        format.html { redirect_to @diorama, notice: 'Diorama was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @diorama.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dioramas/1
  # DELETE /dioramas/1.json
  def destroy
    @diorama.destroy
    respond_to do |format|
      format.html { redirect_to dioramas_url }
      format.json { head :no_content }
    end
  end
  
  def get_model_datum
    @model_datum = ModelDatum.find(params[:id])
    path = @model_datum.textures[0].data.url or ""
    jsonString = { modelData: ActiveSupport::JSON.decode(@model_datum.modeldata), texturePath: path }
    render json: jsonString
  end
  def get_stage
    @stage = Stage.find(params[:id])
    path = @stage.textures[0].data.url or ""
    jsonString = { modelData: ActiveSupport::JSON.decode(@stage.scene_data), texturePath: path }
    render json: jsonString
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diorama
      @diorama = Diorama.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diorama_params
      params.require(:diorama).permit(:title)
    end
end
