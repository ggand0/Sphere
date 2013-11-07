class DioramasController < ApplicationController
  before_action :set_diorama, only: [:show, :edit, :update, :destroy]

  # GET /dioramas
  # GET /dioramas.json
  def index
    @dioramas = Diorama.all
  end

  # GET /dioramas/1
  # GET /dioramas/1.json
  def show
    p("show action has been called.")
    p(@diorama)
    #p(@diorama.stage)
    p(@diorama.model_datum)
    #p(@diorama.model_datum[0].modeldata)
    @stageTextures = @diorama.stage.textures[0]
    @selectedModel = @diorama.model_datum[0]
    p(@stageTextures)
    p(@diorama.stage.textures[0].data.url)
    
    pos = []
    for model_transform in @diorama.model_transforms do
      if (model_transform.transform != nil)
        pos << model_transform.transform
      end
    end
    p(pos)
    @positions = pos
#p(@diorama.model_datum['modeldata'])
  end

  # GET /dioramas/new
  def new
    @diorama = Diorama.new
    
    p("new method was called.")
    # 素材配置のために格納しておく
    @model_data = ModelDatum.all
    @stages = Stage.all
    
    # 選択しているstageとmodeldataを入れる変数
    @selectedModel = ModelDatum.find(37)
    @selectedStage = Stage.find(4)
    @selectedModelTextures = @selectedModel.textures[0]
    @selectedStageTextures = @selectedStage.textures[0]
    
    # 初期値設定
    #@diorama.stage.build
    #@diorama.stage.scene_data = @selectedStage.scene_data
    #@diorama.stage = @selectedStage
    # 無理そうなのでセッションにstage_idを入れておいてcreateする時に使う
    session[:stage_id] = 4
    session[:model_id] = 37
  end

  # GET /dioramas/1/edit
  def edit
  end

  
  def ready
    render :nothing => true
    
    @isReady = true
    p("ready action was called.")
    #p(params)
    #p(params[:code])
      
    for position in params[:code] do
      @trans = ModelTransform.new(:transform => position)
    end
    p(@trans)
    p(@trans.transform)
  end
  
  def findModel
    p("findModel action was called.")
    p(params[:id])
    
    @diorama = Diorama.new
    @model_data = ModelDatum.all
    @stages = Stage.all
    @selectedStage = Stage.find(4)
    @selectedModel = ModelDatum.find(params[:id])
    @selectedStageTextures = @selectedStage.textures[0]
    @selectedModelTextures = @selectedModel.textures[0]
    session[:stage_id] = 4
    session[:model_id] = params[:id]
    p(@selectedModelTextures.data.url)
      
    render :action => "new"
    
=begin
    @selectedModel = ModelDatum.find(37)
       @selectedStage = Stage.find(4)
       @selectedModelTextures = @selectedModel.textures[0]
       @selectedStageTextures = @selectedStage.textures[0]
=end
  end
  
  
  # POST /dioramas
  # POST /dioramas.json
  def create
    #@diorama = Diorama.new(diorama_params)
    p("create action was called.")
    
    @diorama = Diorama.new(:title => params[:diorama][:title])
    p(@diorama.model_transforms)
    
    # Stage追加
    p(@selectedStage)
    p("diorama.stage :")
    #@diorama.stage = @selectedStage
    #@diorama.stage = params[:diorama][:stage]
    @diorama.stage = Stage.find(session[:stage_id])
    
    # ModelTransforms追加
    p(params[:diorama][:model_transforms_attributes])
    p(params[:diorama][:model_transforms_attributes]['0']['transform'])
    
    tmp = params[:diorama][:model_transforms_attributes]['0']['transform']
    posArray = ActiveSupport::JSON.decode(tmp)
    p(posArray)  
    
    #for position in params[:diorama][:model_transforms_attributes]['0']['transform'] do
    for position in posArray do
      # convert array to string
      p(position)
      #@transform = ModelTransform.new(:transform => position.to_sentence)
      @transform = ModelTransform.new(:transform => position)
      @diorama.model_transforms << @transform
    end
#p(@diorama.nothing)
    p(@diorama.model_transforms)

    # ModelData追加
    @diorama.model_datum << ModelDatum.find(session[:model_id])
    
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
