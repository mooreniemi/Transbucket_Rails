# Site navigation targets whose clicks are recorded as ContentEvents of type
# 'Page' (event_type 'open'), so we can tell which header, menu and footer links
# people actually use (News? About? the hamburger?).
#
# The id is what gets stored in content_events.content_id, and the target name
# and surface (header / footer / home) go in event_context. Never renumber or
# reuse an id: recorded events refer to them. Add new targets at the end.
module TrackedTarget
  TARGETS = {
    'news' => 1,
    'about' => 2,
    'terms' => 3,
    'privacy' => 4,
    'discord' => 5,
    'facebook' => 6,
    'twitter' => 7,
    'procedures' => 8,
    'surgeons' => 9,
    'submissions' => 10,
    'compare' => 11,
    'add' => 12,
    'login' => 13,
    'register' => 14,
    'menu' => 15,      # the phone hamburger button
    'language' => 16,  # the language switcher
    'home_cta' => 17,  # the three call-to-action images on the logged-out home page
    'account' => 18,   # the signed-in Account menu
    'safe_mode' => 19  # the safe mode switch in the signed-in header
  }.freeze

  def self.id_for(name)
    TARGETS.fetch(name.to_s)
  end

  def self.valid_id?(id)
    TARGETS.values.include?(id.to_i)
  end
end
