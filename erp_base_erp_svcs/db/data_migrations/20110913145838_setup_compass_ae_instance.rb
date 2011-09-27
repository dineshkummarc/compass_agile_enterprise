class SetupCompassAeInstance
  
  def self.up
    compass_ae_instance = CompassAeInstance.create(version: 3.1)
  end
  
  def self.down
    #remove data here
  end

end
