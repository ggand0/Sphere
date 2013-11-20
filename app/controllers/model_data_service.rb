class ModelDataService
  def initialize
  end
  
  def convert_model_datum(params)
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
    
    # JSON(.js)ファイル削除
    p("Deleting .js file...")
    value = %x(rm -f #{jsfile.path})
    p(value)
    temp.close(true)
    
    return @model_datum
  end
  
end