class ReframeCommunityTrustRoles < ActiveRecord::Migration
  def up
    UserTrustGrant.where(kind: 'established_contributor').update_all(kind: 'vetted')
    UserTrustGrant.where(kind: 'trusted').update_all(kind: 'moderator')
  end

  def down
    UserTrustGrant.where(kind: 'vetted').update_all(kind: 'established_contributor')
    UserTrustGrant.where(kind: 'moderator').update_all(kind: 'trusted')
  end
end
