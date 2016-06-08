module CapybaraHelpers
  def ensure_on(path)
    visit(path) unless current_path == path
  end

  def add_images(images, js: false)
    images.each_with_index do |image, index|
      if js
        add_image_js(image.caption, index)
      else
        add_image(image.caption, index)
      end
    end
  end

  def add_image(caption = nil, index = 0)
    attach_file("pin_pin_images_attributes_#{index}_photo", Rails.root.join("spec", "fixtures", "cat.jpg"), visible: false)
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

