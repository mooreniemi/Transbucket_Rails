Rails.application.config.assets.precompile += %w( search.js pins.js pins/index.js pins/edit.js pins/new.js rated_divs.js )

types = %w( *.png *.gif *.jpg *.eot *.woff *.woff2 *.ttf)
Rails.application.config.assets.precompile += types
