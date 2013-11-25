namespace :procedure do
  desc "create procedures"
  task :create => :environment do

    FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
    MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery"]
    TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
    BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty"]

    bar = RakeProgressbar.new(FTM.count + MTF.count)

    FTM.each {|n| Procedure.new(name: n, gender: 'ftm').save }
    bar.inc
    MTF.each {|n| Procedure.new(name: n, gender: 'mtf').save }
    bar.inc
    Procedure.all.each {|p| p.type = 'top' && p.save if TOP.include?(p.name) }
    bar.inc
    Procedure.all.each {|p| p.type = 'bottom' && p.save if BOTTOM.include?(p.name) }
    bar.finished

  end
end