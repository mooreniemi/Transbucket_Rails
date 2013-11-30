module Constants
  FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
  FTM_IDS = FTM.collect! {|e| Procedure.find_by_name(e).id}

  MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery"]
  MTF_IDS = MTF.collect! {|e| Procedure.find_by_name(e).id}

  TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
  TOP_IDS = TOP.collect! {|e| Procedure.find_by_name(e).id}

  BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty"]
  BOTTOM_IDS = BOTTOM.collect! {|e| Procedure.find_by_name(e).id}

  PROCEDURES = Pin.uniq.pluck(:procedure_id)
  SURGEONS = Pin.uniq.pluck(:surgeon_id)

  SCOPES = ["ftm", "mtf", "bottom", "top", "need_category"]
end