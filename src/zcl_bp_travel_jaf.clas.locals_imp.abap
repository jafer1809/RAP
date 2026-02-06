CLASS lhc_ZI_Travel_jaf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Travel_jaf RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZI_Travel_jaf RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION ZI_Travel_jaf~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION ZI_Travel_jaf~copytravel.

    METHODS recalculate FOR MODIFY
      IMPORTING keys FOR ACTION ZI_Travel_jaf~recalculate.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION ZI_Travel_jaf~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_Travel_jaf RESULT result.
    METHODS validatecystomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_jaf~validatecystomer.
    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_Travel_jaf\_Booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_Travel_jaf.

ENDCLASS.

CLASS lhc_ZI_Travel_jaf IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(wtl_entities) = entities.
    DELETE wtl_entities WHERE TravelId IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*      ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          =  CONV #( lines(  wtl_entities ) )
*      subobject       `  =
*      toyear            =
          IMPORTING
            number            = DATA(wl_latest)
            returncode        = DATA(wl_code)
            returned_quantity = DATA(wl_qty)
        ).
      CATCH cx_number_ranges INTO DATA(wl_error).
        LOOP AT wtl_entities INTO DATA(wel_entity1).
          APPEND VALUE #( %cid = wel_entity1-%cid
                                  %key   = wel_entity1-%key ) TO failed-zi_travel_jaf.
          APPEND VALUE #( %cid = wel_entity1-%cid
                                  %key   = wel_entity1-%key
                                  %msg = wl_error ) TO reported-zi_travel_jaf.

        ENDLOOP.
        EXIT.
        "handle exception
    ENDTRY.

    ASSERT wl_qty = lines( wtl_entities ).
    DATA(wl_current) = wl_latest - wl_qty.
    DATA wtl_travel_jaf TYPE TABLE FOR MAPPED EARLY zi_travel_jaf.
    DATA wel_travel_jaf LIKE LINE OF wtl_travel_jaf.
    LOOP AT wtl_entities INTO DATA(wel_entity).
      wl_current = wl_current + 1.
      wel_travel_jaf = VALUE #( %cid = wel_entity-%cid
                                TravelId = wl_current
       ).
      APPEND wel_travel_jaf TO mapped-zi_travel_jaf.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA wl_max_book TYPE /dmo/booking_id.
    READ ENTITIES OF ZI_Travel_jaf IN LOCAL MODE
    ENTITY ZI_Travel_jaf BY \_booking
    FROM CORRESPONDING #( entities ) LINK DATA(wt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group>) GROUP BY <fs_group>-TravelId.
      wl_max_book = REDUCE #( INIT wl_max = CONV /dmo/booking_id( '0' )
                               FOR is_link IN wt_link_data USING KEY entity WHERE  ( source-TravelId = <fs_group>-TravelId )
                               NEXT  wl_max = COND /dmo/booking_id( WHEN wl_max < is_link-target-BookingId
                                                                         THEN is_link-target-BookingId
                                                                         ELSE  wl_max          )                        ) .
      wl_max_book = REDUCE #( INIT lv_max = wl_max_book
                              FOR is_enity IN entities USING KEY entity WHERE  ( TravelId = <fs_group>-TravelId )
                              FOR is_booking IN is_enity-%target
                              NEXT  lv_max = COND /dmo/booking_id( WHEN lv_max < is_booking-BookingId
                                                                        THEN is_booking-BookingId
                                                                        ELSE  lv_max          )                        ) .
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>) USING KEY entity
      WHERE TravelId = <fs_group>-TravelId  .
        LOOP AT <fs_entity>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>)
        .APPEND  CORRESPONDING #(  <fs_booking> ) TO mapped-zi_booking_jaf ASSIGNING FIELD-SYMBOL(<fs_new>).
          IF <fs_booking>-BookingId IS INITIAL.
            wl_max_book += 10.
*            APPEND  CORRESPONDING #(  <fs_booking> ) TO mapped-zi_booking_jaf ASSIGNING FIELD-SYMBOL(<fs_new>).
            <fs_new>-BookingId = wl_max_book.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
      .
    ENDLOOP.
  ENDMETHOD.

  METHOD accepttravel.

    MODIFY ENTITIES OF  zi_travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
    UPDATE FIELDS ( OverallStatus ) WITH VALUE #( FOR wl_keys IN keys ( %tky = wl_keys-%tky
                                                                        OverallStatus = 'A' ) )
    .

    READ ENTITIES OF zi_travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_result).

    result = VALUE #( FOR wl_result IN wtl_result ( %tky = wl_result-%tky
                                                    %param = wl_result ) ).
  ENDMETHOD.

  METHOD copytravel.

    DATA: wt_travel    TYPE TABLE FOR CREATE zi_travel_jaf,
          wt_booking   TYPE TABLE FOR CREATE zi_travel_jaf\_booking,
          wt_booksuppl TYPE TABLE FOR CREATE zi_booking_jaf\_bookingsuppl.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<fs_key>) WITH KEY %cid = ' '.
    ASSERT <fs_key> IS NOT ASSIGNED.
    READ ENTITIES OF zi_travel_jaf IN LOCAL MODE ENTITY zi_travel_jaf ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_travel_r) FAILED DATA(wtl_failed).

    READ ENTITIES OF zi_travel_jaf IN LOCAL MODE ENTITY zi_travel_jaf BY \_booking ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT DATA(wtl_booking_r) FAILED DATA(wtl_failed_b).

    READ ENTITIES OF zi_travel_jaf IN LOCAL MODE ENTITY zi_booking_jaf BY \_bookingsuppl ALL FIELDS WITH CORRESPONDING #( wtl_booking_r )
    RESULT DATA(wtl_bookingsupp_r) FAILED DATA(wtl_failed_s) REPORTED DATA(wtl_reported).

    LOOP AT wtl_travel_r ASSIGNING FIELD-SYMBOL(<fs_travel>).

*    appeND INITIAL LINE TO wt_travel assIGNING fIELD-SYMBOL(<fs_travel_c>).
*    <fs_travel_c>-%cid = keys[ key entity TravelId = <fs_travel>-TravelId ]-%cid.
*    <fs_travel_c>-%data =  corrESPONDING #( <fs_travel> excEPT TravelId ).
*   new syntax
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <fs_travel>-TravelId ]-%cid
                      %data =  CORRESPONDING #( <fs_travel> EXCEPT TravelId ) )
                      TO wt_travel ASSIGNING FIELD-SYMBOL(<fs_travel_c>).
      <fs_travel_c>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <fs_travel_c>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <fs_travel_c>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref =  <fs_travel_c>-%cid )
          TO wt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>).

      LOOP AT wtl_booking_r ASSIGNING FIELD-SYMBOL(<fs_bo>) USING KEY entity
      WHERE TravelId = <fs_travel>-TravelId .

        APPEND VALUE #( %cid = <fs_travel_c>-%cid && <fs_bo>-BookingId
                       %data =  CORRESPONDING #( <fs_bo> EXCEPT TravelId ) )
                       TO <fs_booking>-%target ASSIGNING FIELD-SYMBOL(<fs_book_c>).
        <fs_book_c>-BookingStatus = 'N'.

        APPEND VALUE #( %cid_ref =  <fs_book_c>-%cid )
          TO wt_booksuppl ASSIGNING FIELD-SYMBOL(<fs_booking_supp>).

        LOOP AT wtl_bookingsupp_r ASSIGNING FIELD-SYMBOL(<fs_bs>) USING KEY entity
         WHERE TravelId = <fs_travel>-TravelId
        AND BookingId = <fs_book_c>-BookingId.
          APPEND VALUE #( %cid = <fs_travel_c>-%cid && <fs_bo>-BookingId && <fs_bs>-BookingSupplementId
                         %data =  CORRESPONDING #( <fs_bs> EXCEPT TravelId BookingId ) )
                         TO <fs_booking_supp>-%target ASSIGNING FIELD-SYMBOL(<fs_booksupp_c>).

        ENDLOOP.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_jaf IN LOCAL MODE
    ENTITY ZI_Travel_jaf
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
    WITH wt_travel
    ENTITY ZI_Travel_jaf
    CREATE BY \_booking
    FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
    WITH wt_booking
    ENTITY Zi_booking_jaf
    CREATE BY \_bookingsuppl
    FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
    WITH wt_booksuppl MAPPED DATA(wt_mapped).

    mapped-zi_travel_jaf = wt_mapped-zi_travel_jaf.


  ENDMETHOD.

  METHOD recalculate.
  ENDMETHOD.

  METHOD rejecttravel.
    MODIFY ENTITIES OF  zi_travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
     UPDATE FIELDS ( OverallStatus ) WITH VALUE #( FOR wl_keys IN keys ( %tky = wl_keys-%tky
                                                                         OverallStatus = 'X' ) )
     .

    READ ENTITIES OF zi_travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_result).

    result = VALUE #( FOR wl_result IN wtl_result ( %tky = wl_result-%tky
                                                    %param = wl_result ) ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF ZI_Travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_travel).
    result = VALUE #(  FOR wl_travel IN wtl_travel
                       ( %tky = wl_travel-%tky
                         %features-%action-accepttravel = COND #(  WHEN wl_travel-OverallStatus = 'A'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-rejecttravel = COND #(  WHEN wl_travel-OverallStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                         %features-%assoc-_booking = COND #(  WHEN wl_travel-OverallStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                                                                    ) ).

  ENDMETHOD.

  METHOD validatecystomer.

    READ ENTITY IN LOCAL MODE zi_travel_jaf
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(WTL_customer).
    DELETE wtl_customer WHERE CustomerId IS INITIAL.
      SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @wtl_customer
      WHERE customer_id = @wtl_customer-CustomerId
      INTO TABLE @DATA(wtl_db_cust).
      IF sy-subrc IS INITIAL.

      ENDIF.

      LOOP AT wtl_customer  ASSIGNING FIELD-SYMBOL(<fs_cust>).
        IF <fs_cust>-CustomerId IS INITIAL OR
        NOT line_exists( wtl_db_cust[ customer_id = <fs_cust>-CustomerId ] ).
          APPEND VALUE #( %tky = <fs_cust>-%tky ) TO failed-zi_travel_jaf.
          APPEND VALUE #( %tky = <fs_cust>-%tky
                          %msg = NEW /dmo/cm_flight_messages(
            textid                = /dmo/cm_flight_messages=>customer_unkown
            customer_id           = <fs_cust>-CustomerId
            severity              = if_abap_behv_message=>severity-error
            )
            %element-CustomerId = if_abap_behv=>mk-on ) TO reported-zi_travel_jaf.

        ENDIF.
      ENDLOOP.



  ENDMETHOD.

ENDCLASS.
