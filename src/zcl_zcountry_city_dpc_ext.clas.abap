class ZCL_ZCOUNTRY_CITY_DPC_EXT definition
  public
  inheriting from ZCL_ZCOUNTRY_CITY_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods CITYSET_GET_ENTITY
    redefinition .
  methods CITYSET_GET_ENTITYSET
    redefinition .
  methods COUNTRYSET_GET_ENTITY
    redefinition .
  methods COUNTRYSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZCOUNTRY_CITY_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA: BEGIN OF ty_final.
            INCLUDE TYPE zcl_zcountry_city_mpc_ext=>ts_country.
            DATA: tocity TYPE zcl_zcountry_city_mpc_ext=>tt_city,
          END OF ty_final.
    DATA: ls_final   LIKE ty_final,
          ls_tocity  TYPE zcl_zcountry_city_mpc_ext=>ts_city,
          ls_country TYPE ztb_country,
          lt_country TYPE TABLE OF ztb_city,
          lt_city    TYPE TABLE OF ztb_city.

    TRY.
        CALL METHOD io_data_provider->read_entry_data
          IMPORTING
            es_data = ls_final.
      CATCH /iwbep/cx_mgw_tech_exception .
    ENDTRY.

    IF ls_final IS NOT INITIAL.
      CLEAR: ls_country.

      MOVE-CORRESPONDING ls_final TO ls_country.

      LOOP AT ls_final-tocity INTO ls_tocity.

        APPEND ls_tocity TO lt_city.
      ENDLOOP.

      INSERT ztb_country FROM ls_country.
      IF sy-subrc EQ 0.
        INSERT ztb_city FROM TABLE lt_city ACCEPTING DUPLICATE KEYS.
      ENDIF.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_final
        CHANGING
          cr_data = er_deep_entity
      ).
    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entity.
    DATA: BEGIN OF ty_final.
            INCLUDE TYPE zcl_zcountry_city_mpc_ext=>ts_country.
            DATA: tocity TYPE zcl_zcountry_city_mpc_ext=>tt_city,
          END OF ty_final.

    DATA: ls_country TYPE ztb_country,
          lt_city    TYPE TABLE OF ztb_city,
          ls_city    TYPE ztb_country,
          ls_final   LIKE ty_final,
          ls_tocity  TYPE zcl_zcountry_city_mpc_ext=>ts_city,
          ls_keyprp  LIKE LINE OF it_key_tab.

    CONSTANTS: cv_navprp TYPE string VALUE 'TOCITY'.

    READ TABLE it_key_tab INTO ls_keyprp WITH KEY name = 'Countrynr'.
    IF sy-subrc EQ 0.
      SELECT SINGLE *
        FROM ztb_country
          INTO ls_country
            WHERE countrynr EQ ls_keyprp-value.

      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_country TO ls_final.

        SELECT *
          FROM ztb_city
            INTO TABLE lt_city
              WHERE cno EQ ls_keyprp-value.

        IF sy-subrc EQ 0.
          SORT lt_city BY cno.

          LOOP AT lt_city INTO ls_city.
            MOVE ls_city TO ls_tocity.

            APPEND ls_tocity TO ls_final-tocity.
          ENDLOOP.
        ENDIF.
      ENDIF.

      IF  ls_final IS NOT INITIAL.
        copy_data_to_ref(
          EXPORTING
            is_data = ls_final
          CHANGING
            cr_data = er_entity
        ).

        INSERT cv_navprp INTO TABLE et_expanded_tech_clauses.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: BEGIN OF ty_final.
            INCLUDE TYPE zcl_zcountry_city_mpc_ext=>ts_country.
            DATA: tocity TYPE zcl_zcountry_city_mpc_ext=>tt_city,
          END OF ty_final.

    DATA: lt_country TYPE TABLE OF ztb_country,
          ls_country TYPE ztb_country,
          lt_city    TYPE TABLE OF ztb_city,
          ls_city    TYPE ztb_country,
          lt_final   LIKE TABLE OF ty_final,
          ls_final   LIKE ty_final,
          ls_tocity  TYPE zcl_zcountry_city_mpc_ext=>ts_city.

    CONSTANTS: cv_navprp TYPE string VALUE 'TOCITY'.

    SELECT *
      FROM ztb_country
        INTO TABLE lt_country.

    IF sy-subrc EQ 0.
      SORT lt_country BY countrynr.

      SELECT *
        FROM ztb_city
          INTO TABLE lt_city.

      IF sy-subrc EQ 0.
        SORT lt_city BY citynr cno.
        LOOP AT lt_country INTO ls_country.
          MOVE-CORRESPONDING ls_country TO ls_final.

          LOOP AT lt_city INTO ls_city WHERE cno EQ ls_country-countrynr.
            MOVE ls_city TO ls_tocity.

            APPEND ls_tocity TO ls_final-tocity.
          ENDLOOP.

          APPEND ls_final TO lt_final.
          CLEAR: ls_final, ls_country.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF lt_final IS NOT INITIAL.
      copy_data_to_ref(
        EXPORTING
          is_data = ls_final
        CHANGING
          cr_data = er_entityset
      ).

      INSERT cv_navprp INTO TABLE et_expanded_tech_clauses.
    ENDIF.
  ENDMETHOD.


  METHOD cityset_get_entity.
    DATA: ls_keyprp LIKE LINE OF it_key_tab.

    READ TABLE it_key_tab INTO ls_keyprp WITH KEY name = 'Citynr'.
    IF  sy-subrc EQ 0.
      SELECT SINGLE *
        FROM ztb_city
          INTO er_entity
            WHERE citynr EQ ls_keyprp-value.
    ENDIF.
  ENDMETHOD.


  METHOD cityset_get_entityset.
    SELECT *
      FROM ztb_city
        INTO TABLE et_entityset.
  ENDMETHOD.


  METHOD countryset_get_entity.
    DATA: ls_keyprp LIKE LINE OF it_key_tab.

    READ TABLE it_key_tab INTO ls_keyprp WITH KEY name = 'Countrynr'.
    IF  sy-subrc EQ 0.
      SELECT SINGLE *
        FROM ztb_country
          INTO er_entity
            WHERE countrynr EQ ls_keyprp-value.
    ENDIF.
  ENDMETHOD.


  METHOD countryset_get_entityset.
    SELECT *
      FROM ztb_country
        INTO TABLE et_entityset.
  ENDMETHOD.
ENDCLASS.
