#from https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
module ControllerHelpers
  def sign_in(user = build(:user))
    if user.nil?
      request.env['warden'].stub(:authenticate!).
        and_throw(:warden, {:scope => :user})
      controller.stub :current_user => nil
    else
      request.env['warden'].stub :authenticate! => user
      controller.stub :current_user => user
    end
  end
end
