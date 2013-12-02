class StagesController < ApplicationController
  before_action :set_stage, only: [:show, :edit, :update, :destroy]

  # GET /stages
  # GET /stages.json
  def index
    @stages = Stage.all
  end

  # GET /stages/1
  # GET /stages/1.json
  def show
    @data = ActiveSupport::JSON.decode(@stage.scene_data)
    @textures = @stage.textures
    unless @stage.textures.nil?
      @urls = @stage.textures.map{ |texture| texture.data.url }
    end
  end

  # GET /stages/new
  def new
    @stage = Stage.new
    @textures = Texture.new
  end

  # GET /stages/1/edit
  def edit
  end

  # POST /stages
  # POST /stages.json
  def create
    # JSONファイルから文字列を抽出する
    file = params['stage']['file']
    
    @jsonstring = file.read
    @stage = Stage.new(scene_data: @jsonstring, title: params[:stage][:title])

    unless params[:stage][:texture].nil?
      @textures = Texture.new(:data => params[:stage][:texture]['data'])
      @stage.textures << @textures
    end

    respond_to do |format|
      if @stage.save!
        format.html { redirect_to @stage, notice: 'Stage was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stage }
      else
        format.html { render action: 'new' }
        format.json { render json: @stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stages/1
  # PATCH/PUT /stages/1.json
  def update
    respond_to do |format|
      if @stage.update(stage_params)
        format.html { redirect_to @stage, notice: 'Stage was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stages/1
  # DELETE /stages/1.json
  def destroy
    @stage.destroy
    respond_to do |format|
      format.html { redirect_to stages_url }
      format.json { head :no_content }
    end
  end
  
  def get_contents
    @stage = Stage.find(params[:id])
      
    # If modeldata has at least one texture, set the path
    path = @stage.textures[0].data.url or ""
    jsonString = { modelData: ActiveSupport::JSON.decode(@stage.scene_data), texturePath: path }

    render json: jsonString
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stage
      @stage = Stage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stage_params
      #params[:stage]
      params.require(:stage).permit(:scene_data, :textures)
    end
end
