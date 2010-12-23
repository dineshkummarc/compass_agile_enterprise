
#Tell ActionController to send itself an include message with the
#module: ControllerBasedTabs

ActionController::Base.send(:include, ControllerBasedTabs) 
