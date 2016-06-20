module Constants
  MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery", "orchiectomy"]
  MTF_IDS = [7, 8, 9, 55]

  FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
  FTM_IDS = [1, 2, 3, 4, 5, 6]

  TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
  TOP_IDS = [8, 2, 3, 4, 6]

  BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty", "orchiectomy"]
  BOTTOM_IDS = [7, 1, 5, 55]

  PROCEDURES = Pin.uniq.pluck(:procedure_id)
  SURGEONS = Pin.uniq.pluck(:surgeon_id)

  SCOPES = ["ftm", "mtf", "bottom", "top", "need_category"]
end
