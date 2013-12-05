class ModelDataService
  def convert_model_datum(params)
    require 'tempfile'
    
    # アップロードされたファイルをmodel/my_dataに一時的に保存する
    file = params[:model_datum][:file]
    jsonstring = ''
    python_path = CONFIG['python_path']
    tmp_dir_path = CONFIG['tmp_file_path']
    script_path = CONFIG['script_path']

    # tmpfile作成
    temp = Tempfile::new('foo', tmp_dir_path)
    temp << file.read
    
    # tmpdir内に変換したファイルを出力させる
    Dir.mktmpdir('hoge') do |dir|
      out_file_path = File.join(dir, ('a'...'z').to_a.shuffle.join()+'.js')
      
      # JSON形式に変換
      # テクスチャurlに余計なパスが含まれる問題を、変換前ファイルとスクリプトファイルを同階層に置くことで解決している。
      value = %x(#{python_path} #{script_path} #{temp.path} #{out_file_path} 2>&1)
      puts 'Conversion result : '
      puts value
      
      # DBに文字列としてJSONファイルの内容を格納
      jsfile = open(out_file_path)
      while line = jsfile.gets
        jsonstring += line
      end
    end

    # ModelDatumを生成して返す
    model_datum = ModelDatum.new(modeldata: jsonstring, title: params[:model_datum][:title])
    unless params[:model_datum][:texture].nil?
      params[:model_datum][:texture][:model_datum][:textures].each do |file|
        texture = Texture.new(data: file)
        model_datum.textures << texture
      end
    end
    
    temp.close(true)
    model_datum
  end
end