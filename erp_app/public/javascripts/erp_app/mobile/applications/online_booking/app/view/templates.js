Compass.ErpApp.Mobile.OnlineBooking.searchResultTemplate = new Ext.XTemplate(
  '<div class="x-docking-horizontal">',
  '<div class="x-img" style="background-image:url({image_url});"></div>',
  '<div class="x-body">',
  '<span class="label">Price</span><span class="value">{display_price}</span>',
  '&nbsp;&nbsp;<span class="label"># Available</span><span class="value">{number_available}</span>',
  '<br/>',
  '<span class="label">Travel From Date</span><span class="value">{check_in_date:date("m/d/Y")}</span> - <span class="label">Travel To Date</span><span class="value">{check_out_date:date("m/d/Y")}</span>',
  '<br/><br/>',
  '<span>{description}</span>',
  '</div>',
  '</div>'
  );

Compass.ErpApp.Mobile.OnlineBooking.emptyResults = new Ext.XTemplate(
  '<div class="confirmation">',
  'Sorry we could not find anything.',
  '</div>'
  );

Compass.ErpApp.Mobile.OnlineBooking.reservationConfirmationRoomInfo = new Ext.XTemplate(
  '<div class="summary">',
  '<span>Accomodation Information</span>',
  '<br/><br/>',
  '<div class="x-img" style="background-image:url({accomodationUnitTypeUrl});"></div>',
  '<span>Confirmation #</span><span>{confirmation_number}</span>',
  '<br/>',
  '<span>Price</span><span>{display_price}</span>',
  '<br/>',
  '<span>{travel_from_date:date("m/d/Y")}</span> - <span>{travel_to_date:date("m/d/Y")}</span>',
  '<br/><br/>',
  '<span>{accomodationUnitTypeDescription}</span>',
  '<br/><br/>',
  '<p>{accomodationUnitTypeLongDescription}</p>',
  '</div>'
  );

  Compass.ErpApp.Mobile.OnlineBooking.reservationConfirmationTravelerInfo = new Ext.XTemplate(
  '<div class="summary">',
  '<span>Guest Information</span>',
  '<br/><br/>',
  '<span>{first_name}</span>',
  '<span>{last_name}</span>',
  '<br/>',
  '<span>{address_line_1}</span>',
  '<span>{address_line_2}</span>',
  '<br/>',
  '<span>{country}</span>',
  '<span>{state}</span>',
  '<br/>',
  '<span>{city}</span>',
  '<span>{zipcode}</span>',
  '<br/>',
  '<span>{email}</span>',
  '<br/>',
  '<span>{phone}</span>',
  '<br/></br/>',
  '<span id="emailConfirmationBtnHolder"></span>',
  '<br/>',
  '<span id="mapItBtnHolder"></span>',
  '</div>'
  );


