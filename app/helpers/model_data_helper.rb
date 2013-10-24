module ModelDataHelper
  def add_texture(form_builder)
    link_to_function "add", :id  => "add_texture" do |page|
      form_builder.fields_for :textures, Texture.new, :child_index => 'NEW_RECORD' do |texture_form|
        html = render(:partial => 'texture', :locals => { :f => texture_form })
        page << "$('add_texture').insert({ before: '#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
      end
    end
  end
  def delete_texture(form_builder)
    if form_builder.object.new_record?
      link_to_function("Remove this Texture", "this.up('fieldset').remove()")
    else
      form_builder.hidden_field(:_delete) +
      link_to_function("Remove this Texture", "this.up('fieldset').hide(); $(this).previous().value = '1'")
    end
  end
  
end
