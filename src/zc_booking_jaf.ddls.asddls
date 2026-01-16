@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for booking'
@Metadata.ignorePropagatedAnnotations: true
define view entity zc_booking_jaf
  as projection on Zi_booking_jaf
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _bookingsuppl : redirected to composition child zc_bookingsupp_jaf,
      _carrier,
      _connection,
      _customer,
      _status,
      _travel : redirected to parent ZC_travel_jaf 
}
