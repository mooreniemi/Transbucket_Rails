class TrustGrantsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @query = params[:query].to_s.strip[0, 80]
    @search_ready = @query.length >= 3
    @users = if @search_ready
      # This is deliberately search-first: loading every member would be slow
      # and makes an admin screen needlessly expose the whole directory.
      term = "%#{@query.downcase}%"
      User.includes(:trust_grants).
        where('LOWER(username) LIKE :term OR LOWER(name) LIKE :term OR LOWER(email) LIKE :term', term: term).
        order(:username).
        limit(25)
    else
      User.where('1 = 0')
    end
  end

  def create
    user = User.find(params[:user_id])
    user.grant_trust!(trust_grant_params[:kind], granted_by: current_user, internal_note: trust_grant_params[:internal_note])

    redirect_to trust_grants_path, notice: "Trust level updated for #{user.username}."
  end

  def destroy
    grant = UserTrustGrant.find(params[:id])
    return head(:forbidden) unless grant.source == 'moderator'

    grant.update_attributes!(revoked_at: Time.current)

    redirect_to trust_grants_path, notice: "#{grant.kind.humanize} revoked."
  end

  private

  def require_admin!
    head :forbidden unless current_user.admin?
  end

  def trust_grant_params
    params.require(:user_trust_grant).permit(:kind, :internal_note)
  end
end
