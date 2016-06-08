def confirm_attributes(form, model)
  model.attributes.each do |key, value|
    case key
    when 'updated_at', 'created_at',
         'procedure_id', 'surgeon_id',
         'image_file_name', 'image_content_type', 'image_file_size', 'image_updated_at',
         'photo_file_name', 'photo_content_type', 'photo_file_size', 'photo_updated_at',
         'username'
      next
    else expect(form.send(key)).to eq(value)
    end
  end
end
