CLASS lhc_zi_booking_jaf DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Zi_booking_jaf\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Zi_booking_jaf RESULT result.

ENDCLASS.

CLASS lhc_zi_booking_jaf IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA wl_max_book TYPE /dmo/booking_supplement_id.
    READ ENTITIES OF ZI_travel_jaf IN LOCAL MODE
    ENTITY ZI_booking_jaf BY \_bookingsuppl
    FROM CORRESPONDING #( entities ) LINK DATA(wt_link_data).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group>) GROUP BY <fs_group>-%tky.
      wl_max_book = REDUCE #( INIT wl_max = CONV /dmo/booking_supplement_id( '0' )
                               FOR is_link IN wt_link_data USING KEY entity WHERE  ( source-TravelId = <fs_group>-TravelId AND
                                                                                     source-BookingId = <fs_group>-BookingId  )

                               NEXT  wl_max = COND /dmo/booking_supplement_id( WHEN wl_max < is_link-target-BookingSupplementId
                                                                         THEN is_link-target-BookingSupplementId
                                                                         ELSE  wl_max          )                        ) .
      wl_max_book = REDUCE #( INIT lv_max = wl_max_book
                              FOR is_enity IN entities USING KEY entity WHERE  ( TravelId = <fs_group>-TravelId AND
                                                                                 BookingId = <fs_group>-BookingId )
                              FOR is_booking IN is_enity-%target
                              NEXT  lv_max = COND /dmo/booking_supplement_id( WHEN lv_max < is_booking-BookingSupplementId
                                                                        THEN is_booking-BookingSupplementId
                                                                        ELSE  lv_max          )                        ) .
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>) USING KEY entity
      WHERE TravelId = <fs_group>-TravelId AND BookingId = <fs_group>-BookingId .
        LOOP AT <fs_entity>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>)
        .APPEND  CORRESPONDING #(  <fs_booking> ) TO mapped-zi_bookingsupp_jaf ASSIGNING FIELD-SYMBOL(<fs_new>).
          IF <fs_booking>-BookingSupplementId IS INITIAL.
            wl_max_book += 10.

            <fs_new>-BookingSupplementId = wl_max_book.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
      .
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
   READ ENTITIES OF ZI_Travel_jaf IN LOCAL MODE ENTITY ZI_Travel_jaf
   by \_booking
    FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(wtl_booking).
    result = VALUE #(  FOR wl_booking IN wtl_booking
                       ( %tky = wl_booking-%tky
                         %features-%assoc-_bookingsuppl = COND #(  WHEN wl_booking-BookingStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                                                                    ) ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
