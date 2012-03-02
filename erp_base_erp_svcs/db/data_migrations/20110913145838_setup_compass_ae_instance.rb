class SetupCompassAeInstance
  
  def self.up
    CompassAeInstance.create(version: 3.0)
  end
  
  def self.down
    #remove data here
  end

end
