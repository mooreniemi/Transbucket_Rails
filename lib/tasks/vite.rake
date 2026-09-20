namespace :vite do
  desc 'Build the react/ Vite app and copy its output into public/vite for the react_app layout to serve in production'
  task :build do
    react_dir = Rails.root.join('react')
    public_dir = Rails.root.join('public', 'vite')

    sh "cd #{react_dir} && npm run build"

    FileUtils.rm_rf(public_dir)
    FileUtils.cp_r(react_dir.join('dist'), public_dir)

    puts "Copied #{react_dir.join('dist')} -> #{public_dir}"
  end
end
