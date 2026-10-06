require 'rails_helper'

# Who can read a restricted discussion, beyond the rules in
# comment_visibility_spec.rb: its author, moderators, and for "people who
# posted a submission for X", anyone who posted one for X or a related procedure.
RSpec.describe Comment do
  let(:phalloplasty) { create(:procedure, name: 'phalloplasty') }
  let(:rff) { create(:procedure, name: 'rff phalloplasty') }
  let(:vaginoplasty) { create(:procedure, name: 'vaginoplasty') }
  let(:asker) { create(:user) } # pre-op: no submissions yet

  def discussion(visibility, on: phalloplasty, by: asker)
    CommentService.new(on, by, 'How was recovery?', nil, visibility).tap(&:create).comment
  end

  def visible?(comment, user)
    Comment.visible_to(user).where(id: comment.id).exists?
  end

  it "always shows authors their own restricted discussions and the replies in them" do
    root = discussion('subject_contributors')
    replier = create(:user).tap { |u| create(:pin, user: u, procedure: phalloplasty) }
    reply = CommentService.new(phalloplasty, replier, 'Six weeks.', root.id).tap(&:create).comment

    expect(visible?(root, asker)).to eq(true)
    expect(visible?(reply, asker)).to eq(true)
  end

  it 'shows restricted discussions to moderators' do
    moderator = create(:user).tap { |u| u.grant_trust!('moderator') }

    expect(visible?(discussion('subject_contributors'), moderator)).to eq(true)
    expect(visible?(discussion('contributors'), moderator)).to eq(true)
  end

  it 'counts a submission about a related procedure as posting about the subject' do
    rff_person = create(:user).tap { |u| create(:pin, user: u, procedure: rff) }
    vaginoplasty_person = create(:user).tap { |u| create(:pin, user: u, procedure: vaginoplasty) }
    comment = discussion('subject_contributors')

    expect(visible?(comment, rff_person)).to eq(true)
    expect(visible?(comment, vaginoplasty_person)).to eq(false)
  end

  it 'still keeps a restricted discussion from someone who has not posted about it' do
    expect(visible?(discussion('subject_contributors'), create(:user))).to eq(false)
    expect(visible?(discussion('contributors'), create(:user))).to eq(false)
  end

  it "describes its audience in plain words, naming the subject" do
    expect(discussion('everyone').audience_label).to be_nil
    expect(discussion('contributors').audience_label).to eq('People who have posted a submission')
    expect(discussion('subject_contributors').audience_label).to eq('People who posted a submission for phalloplasty')
  end

  it 'names a surgeon the same way: a submission with them, not a post about them' do
    surgeon = create(:surgeon)

    expect(discussion('subject_contributors', on: surgeon).audience_label).to eq("People who posted a submission with #{surgeon}")
  end
end
