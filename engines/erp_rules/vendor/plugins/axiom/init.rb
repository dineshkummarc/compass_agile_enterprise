# Include hook code here
if Rails.env=='development'
  reloadable_paths=[
    "/vendor/plugins/axiom/jlib",
     "/vendor/plugins/axiom/jlib/collections"
     
  ]

  reloadable_paths.each do |r|
    reloadable_path = RAILS_ROOT + r
    ActiveSupport::Dependencies.load_once_paths.delete(reloadable_path)
  end
  ActiveSupport::Dependencies.load_once_paths.to_yaml
end
