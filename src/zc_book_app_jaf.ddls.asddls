@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for approver'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_book_app_jaf as projection on ZI_BOOKING_JAF
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
      _bookingsuppl,
//      _bookingsuppl : redirected to composition child Zc_BOOKINGSUPP_JAF,
      _carrier,
      _connection,
      _customer,
      _status,
      _travel : redirected to parent ZC_travel_app_jaf 
}
