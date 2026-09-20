class AddPronounsToUsers < ActiveRecord::Migration
  # Free text in a strict "they/them" shape (see User::PRONOUNS_FORMAT). NULL
  # means "not chosen", and pins then fall back to the gender-derived pronouns
  # they have always shown, so nothing has to be backfilled.
  def change
    add_column :users, :pronouns, :string
  end
end
