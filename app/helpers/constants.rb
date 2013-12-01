module Constants
  FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
  FTM_IDS = FTM.collect! {|e| Procedure.find_by_name(e).id} unless Procedure.all.empty?

  MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery"]
  MTF_IDS = MTF.collect! {|e| Procedure.find_by_name(e).id} unless Procedure.all.empty?

  TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
  TOP_IDS = TOP.collect! {|e| Procedure.find_by_name(e).id} unless Procedure.all.empty?

  BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty"]
  BOTTOM_IDS = BOTTOM.collect! {|e| Procedure.find_by_name(e).id} unless Procedure.all.empty?

  PROCEDURES = Pin.uniq.pluck(:procedure_id)
  SURGEONS = Pin.uniq.pluck(:surgeon_id)

  SCOPES = ["ftm", "mtf", "bottom", "top", "need_category"]
end