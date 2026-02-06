@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface for booking suppliment'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_bookingsupp_jaf
  as select from zbookingsupp_jaf
  association        to parent Zi_booking_jaf as _booking        on  $projection.BookingId = _booking.BookingId
                                                                 and $projection.TravelId  = _booking.TravelId
  association [1..1] to ZI_Travel_jaf         as _travel         on  $projection.TravelId = _travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _supplement     on  $projection.BookingSupplementId = _supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _supplementtext on  $projection.BookingSupplementId = _supplementtext.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      _supplement,
      _supplementtext,
      _booking,
      _travel
}
