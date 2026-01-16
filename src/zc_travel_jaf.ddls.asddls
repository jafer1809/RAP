@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_travel_jaf
  provider contract transactional_query
  as projection on ZI_Travel_jaf
{
  key TravelId,
      AgencyId,
      _Agency.Name as agencyname,
      CustomerId,
      _customer.LastName as customername,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      _status._Text.Text :localized,
//      CreatedBy,
//      CreatedAt,
//      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _booking: redirected to composition child zc_booking_jaf,
      _currency,
      _customer,
      _status
}
