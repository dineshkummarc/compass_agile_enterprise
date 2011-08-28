Rails.application.routes.draw do

  mount Console::Engine => "/console"
end
