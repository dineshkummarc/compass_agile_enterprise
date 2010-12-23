module ControllerBasedTabs
#****************************************************************************************
# Perform initialization when this module is included.
#
# base.extend() is used to add the class methods to the class that this module
# is being included in (in this case, ActionController)
#****************************************************************************************
  def self.included(base)
#    puts "ControllerBasedTabs file included, executing extend for class methods..."
    base.extend(ClassMethods)
  end
 #****************************************************************************************
 # Class methods go here
 #****************************************************************************************
  module ClassMethods
    
    #The syntax for setting up the class-instance variable is different here because this
    #is a module that is extended than what it would be if we were doing this inside the 
    #class itself. What you typically see in tutorials is this syntax:
    #class << self; attr_accessor :tn end
    #which would be correct if we were doing this inside the class itself (in this case,
    #if this code was inside the controller class.
    #But we are in a module, that is worked into the class via extend, so the syntax:
    attr_accessor :tn
    #is how we've gone
    
    def controller_based_tabs( tab_nav_name )
      
      #Show that self in this case is the controller class itself, not an instance
      #of that class
      #puts self.to_s
     
      @tn = tab_nav_name.to_sym
      
      #Show the class-instance variable's value
      #puts self.tn
   
    end  
  end
 #****************************************************************************************
 # Instance methods go here
 #****************************************************************************************  
  def initialize
    #For tutorial purposes. Show when we are in scope.
    #puts "initializing instance tn."
    #Show that self in this case is an instance of the controller class
    #puts self.to_s
    super
    @controller_tabs = nil
    #If the tab_nav has been set via the controller, we will use that value,
    #otherwise, we'll use a default tab_nav, which is usually no tabs
    if self.class.tn then
      @controller_tabs = self.class.tn
    else
      @controller_tabs = :application_default
    end
    #puts @controller_tabs
    
  end
  
end