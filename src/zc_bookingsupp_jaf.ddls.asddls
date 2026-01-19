@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for supplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Zc_BOOKINGSUPP_JAF
  as projection on zi_bookingsupp_jaf
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text: {
           element: [ 'supplementDesc' ]
          }
      SupplementId,
      _supplementtext.Description as supplementDesc : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _booking : redirected to parent zc_booking_jaf,
      _supplement,
      _supplementtext,
      _travel  : redirected to ZC_travel_jaf
}
