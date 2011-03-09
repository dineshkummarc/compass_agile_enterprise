class SignupController < BaseController
  def show
    @user = User.new
  end
  
  def new
    ignored_params = %w{action controller}

    options = params
    options.delete_if{|k,v| ignored_params.include?(k.to_s)}
    options = options[:user]

    @user = User.new(options)
    if @user.save
      @user.activated_at = Time.now
      @user.roles << @site.site_role
      @user.save
    end
  end

  #no section to set
  def set_section
    return false
  end
end
