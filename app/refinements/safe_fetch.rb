module SafeFetch
  refine Hash do
    def safe_fetch(k)
      self[k].to_h
    end
  end
end
