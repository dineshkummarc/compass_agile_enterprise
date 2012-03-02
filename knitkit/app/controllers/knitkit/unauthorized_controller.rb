module Knitkit
  class UnauthorizedController < BaseController

    def index
      @current_user = nil
    end

    #no section to set
    def set_section
      return false
    end
  end
end
