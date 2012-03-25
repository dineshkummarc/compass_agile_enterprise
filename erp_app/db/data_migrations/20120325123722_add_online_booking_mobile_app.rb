class AddOnlineBookingMobileApp
  
  def self.up
    if MobileApplication.find_by_internal_identifier('online_booking').nil?
      MobileApplication.create(
        :description => 'Online Booking',
        :icon => 'icon-house',
        :javascript_class_name => 'onlineBooking',
        :internal_identifier => 'online_booking'
      )
      
    end
  end
  
  def self.down
    MobileApplication.find_by_internal_identifier('online_booking').destroy
  end

end
