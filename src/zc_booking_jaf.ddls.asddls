@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_booking_jaf
  as projection on Zi_booking_jaf
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text: {
       element: [ 'customername' ]
      }
      CustomerId,
      _customer.LastName as customername,
      @ObjectModel.text: {
       element: [ 'carriername' ]
      }
      CarrierId,
      _carrier.Name as carriername,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
        @Consumption.valueHelpDefinition: [{ entity: {
                                          name: 'I_Currency',
                                          element: 'Currency'
                                      } }]
      CurrencyCode,
       @ObjectModel.text: {
         element: [ 'statustext' ]
      }
      BookingStatus,
      _status._Text.Text as statustext : localized,
      LastChangedAt,
      /* Associations */
      _bookingsuppl : redirected to composition child Zc_BOOKINGSUPP_JAF,
      _carrier,
      _connection,
      _customer,
      _status,
      _travel : redirected to parent ZC_travel_jaf 
}
