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
    @textures = @stage.textures[0]
    if !@stage.textures.empty?
      p(@stage.textures)
      p("debug texture url:")
      p(@textures.data.url)
    end
    p("debug scene_data:")
    p(@stage)
  end

  # GET /stages/new
  def new
    @stage = Stage.new
  end

  # GET /stages/1/edit
  def edit
  end

  # POST /stages
  # POST /stages.json
  def create
    #@stage = Stage.new(stage_params)
    
    # JSONファイルから文字列を抽出する
    file = params['stage']['file']# Upされたファイルにアクセス
    
=begin
    jsfile = File.open(defPath + file.original_filename, 'r')
    @jsonstring = ""
    while line = file.gets
      @jsonstring += line
    end
=end
    
    p("file params:")
    #p(params['stage']['file'])
    
    @jsonstring = file.read
    p(@jsonstring)
    @stage = Stage.new(:scene_data => @jsonstring, :title => params[:stage][:title])
    p("stage.scene_data:")
    p(@stage.scene_data)
    #p(@stage.nothing)
      
    if params[:stage][:texture] != nil
      @textures = Texture.new(:data => params[:stage][:texture]['data'])
      @stage.textures << @textures
    end

    respond_to do |format|
      if @stage.save
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
