module CapybaraHelpers
  def ensure_on(path)
    visit(path) unless current_path == path
  end

  def add_images(images, js: false, offset: 0)
    images.each_with_index do |image, index|
      if js
        add_image_js(image.caption, index + offset)
      else
        add_image(image.caption, index + offset)
      end
    end
  end

  def add_image(caption = nil, index = 0)
    attach_file("pin_pin_images_attributes_#{index}_photo", Rails.root.join("spec", "fixtures", "cat.jpg"))
    fill_in "pin_pin_images_attributes_#{index}_caption", :with => caption unless caption.nil?
  end

  def add_image_js(caption = nil, index = 0)
    find(".dz-hidden-input", visible: false)
    page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")

    attach_file("dz-file-input", Rails.root.join("spec", "fixtures", "cat.jpg"), visible: false)

    expect(page).to have_selector(".dz-image-preview img[alt]:not([alt=''])", count: index + 1)

    preview = all(".dz-image-preview")[index]

    expect(preview.find('img')[:alt]).to eql("cat.jpg")

    preview.fill_in("Caption", :with => caption) unless caption.nil?
  end

  def gen_pin_data
    { :cost => rand(999),
      :experience => Faker::Lorem.sentences(3).join(" ")
    }
  end

  def enter_details(pin_data, js: false)
    fill_in "Cost", :with => pin_data[:cost]

    if js
      page.execute_script("tinyMCE.activeEditor.setContent('#{pin_data[:experience]}')")
      within_frame("pin_details_ifr") do
        expect(page).to have_content(pin_data[:experience])
      end
    else
      fill_in "pin_details", :with => pin_data[:experience]
    end
  end

  def select_in_chosen(chosen_id, item)
    page.execute_script("$('##{chosen_id}').trigger('chosen:open')")
    within("##{chosen_id}_chosen") do
      field_selector = ".chosen-search input[type='text']"
      field = find(field_selector).native
      field.send_keys("#{item}")
      field.send_keys(:return)
    end
  end

  def select_in_field(field_id, item, js: false)
    if js
      select_in_chosen field_id, item
    else
      select item, :from => field_id
    end
  end

  def add_surgeon(surgeon, js: false)
    if js
      find("#add_new_surgeon").click
    end

    within("#surgeon_container") do
      fill_in "Surgeon's last name", :with => surgeon.last_name
      fill_in "Surgeon's first name", :with => surgeon.first_name
      fill_in "Surgeon's URL", :with => surgeon.url
    end
  end

  def add_procedure(procedure, js: false)
    if js
      find("#add_new_procedure").click
    end

    within("#procedure_container") do
      fill_in "Name of procedure", :with => procedure.name
      select procedure.body_type, :from => "pin_procedure_attributes_body_type"
      select procedure.gender, :from => "pin_procedure_attributes_gender"
    end
  end

  def check_surgeon_and_procedure(surgeon, procedure)
    details = find("dl")
    expect(details).to have_content(surgeon.last_name)
    expect(details).to have_content(procedure.name)
  end

  def check_pin_data(pin_data)
    expect(find('dl')).to have_content(pin_data[:cost])

    experience_section = find("#details")
    expect(experience_section).to have_content(pin_data[:experience])
  end

  def check_photos(new_images)
    new_images.each do |pin_image|
      expect(page).to have_selector(".thumbnail .caption", text: pin_image.caption)
    end
  end
end

