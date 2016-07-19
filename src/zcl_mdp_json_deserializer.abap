
CLASS zcl_mdp_json_deserializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: deserialize IMPORTING json TYPE string EXPORTING node TYPE REF TO zcl_mdp_json_node
      RAISING zcx_mdp_json_invalid .
  PRIVATE SECTION.
    CLASS-METHODS:
    deserialize_node
        IMPORTING json TYPE string
                  offset_before TYPE i
        EXPORTING jsonnode TYPE REF TO zcl_mdp_json_node
                  offset_after TYPE i
        RAISING zcx_mdp_json_invalid

   ,deserialize_object
        IMPORTING json TYPE string
                  offset_before TYPE i
        EXPORTING jsonnode TYPE REF TO zcl_mdp_json_node
                  offset_after TYPE i
        RAISING  zcx_mdp_json_invalid

   ,deserialize_array
        IMPORTING json TYPE string
                  offset_before TYPE i
        EXPORTING jsonnode TYPE REF TO zcl_mdp_json_node
                  offset_after TYPE i
        RAISING zcx_mdp_json_invalid .

    CONSTANTS: co_debug_mode TYPE i VALUE 0.

ENDCLASS.



CLASS ZCL_MDP_JSON_DESERIALIZER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_DESERIALIZER=>DESERIALIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        STRING
* | [<---] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* | [!CX!] ZCX_MDP_JSON_INVALID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deserialize.

    DATA : l_jsonnode TYPE REF TO zcl_mdp_json_node.

    deserialize_node(
  EXPORTING
    json = json
    offset_before = 0
  IMPORTING
    jsonnode = l_jsonnode ) .

    node = l_jsonnode.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_MDP_JSON_DESERIALIZER=>DESERIALIZE_ARRAY
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        STRING
* | [--->] OFFSET_BEFORE                  TYPE        I
* | [<---] JSONNODE                       TYPE REF TO ZCL_MDP_JSON_NODE
* | [<---] OFFSET_AFTER                   TYPE        I
* | [!CX!] ZCX_MDP_JSON_INVALID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deserialize_array.
    DATA l_json TYPE string.
    l_json = json.

    DATA l_offset TYPE i.
    l_offset = offset_before.

    DATA l_len TYPE i.

    DATA : l_array_jsonnode TYPE REF TO zcl_mdp_json_node.
    CREATE OBJECT l_array_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_array.

    IF co_debug_mode = 1.
      WRITE: / 'array:' .
    ENDIF.

    DO.

*  ] end
      DATA l_submatch TYPE string.
      FIND REGEX '\A\s*(\]|,)' IN SECTION OFFSET l_offset OF json
             MATCH OFFSET l_offset MATCH LENGTH l_len
             SUBMATCHES l_submatch.
      CASE l_submatch.
        WHEN ']'.
          l_offset = l_offset + l_len .
          offset_after = l_offset.
          EXIT.
        WHEN ','.
          l_offset = l_offset + l_len .
      ENDCASE.


      DATA : l_jsonnode TYPE REF TO zcl_mdp_json_node.


      DATA : wa_array_children TYPE zcl_mdp_json_node=>typ_array_children .

      deserialize_node( EXPORTING json = l_json offset_before = l_offset
        IMPORTING jsonnode = l_jsonnode offset_after = l_offset ).

      wa_array_children-node = l_jsonnode .

      APPEND wa_array_children TO l_array_jsonnode->array_children.

      offset_after = l_offset.

    ENDDO.
    jsonnode = l_array_jsonnode .

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_MDP_JSON_DESERIALIZER=>DESERIALIZE_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        STRING
* | [--->] OFFSET_BEFORE                  TYPE        I
* | [<---] JSONNODE                       TYPE REF TO ZCL_MDP_JSON_NODE
* | [<---] OFFSET_AFTER                   TYPE        I
* | [!CX!] ZCX_MDP_JSON_INVALID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deserialize_node.

    DATA l_json TYPE string.
    l_json = json.

    DATA l_offset TYPE i.
    l_offset = offset_before.

    DATA l_len TYPE i.

    DATA : l_jsonnode TYPE REF TO zcl_mdp_json_node.

    FIND REGEX '\{|\[|"|\d|t|f' IN SECTION OFFSET l_offset OF json
    MATCH OFFSET l_offset.

    CASE l_json+l_offset(1).
      WHEN '{'.
        l_offset = l_offset + 1.
        deserialize_object( EXPORTING json = l_json offset_before = l_offset IMPORTING jsonnode = l_jsonnode offset_after = l_offset ).
        jsonnode = l_jsonnode.
        offset_after = l_offset.
      WHEN '['.
        l_offset = l_offset + 1.
        deserialize_array( EXPORTING json = l_json offset_before = l_offset IMPORTING jsonnode = l_jsonnode offset_after = l_offset ).
        jsonnode = l_jsonnode.
        offset_after = l_offset.
      WHEN '"'.
        DATA l_submatch TYPE string.

        FIND REGEX '"([^"]*)"' IN SECTION OFFSET l_offset OF json
        MATCH OFFSET l_offset MATCH LENGTH l_len
        SUBMATCHES l_submatch.
        IF co_debug_mode = 1.
          WRITE: / 'string:' , l_submatch.
        ENDIF.


        CREATE OBJECT l_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_string.
        l_jsonnode->value = l_submatch .

        offset_after = l_offset + l_len.
      WHEN 't'.
        IF l_json+l_offset(4) = 'true'.
          CREATE OBJECT l_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_true.
          l_jsonnode->value = l_json+l_offset(4).
          offset_after = l_offset + 4.

          IF co_debug_mode = 1.
            WRITE: / 'true'  .
          ENDIF.
        ELSE.
          RAISE EXCEPTION TYPE zcx_mdp_json_invalid.
        ENDIF.

      WHEN 'n'.
        IF l_json+l_offset(4) = 'null'.
          CREATE OBJECT l_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_null.
          l_jsonnode->value = l_json+l_offset(4).
          offset_after = l_offset + 4.

          IF co_debug_mode = 1.
            WRITE: / 'null'  .
          ENDIF.
        ELSE.
          RAISE EXCEPTION TYPE zcx_mdp_json_invalid.
        ENDIF.
      WHEN 'f'.
        IF l_json+l_offset(5) = 'false'.
          CREATE OBJECT l_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_false.
          l_jsonnode->value = l_json+l_offset(5).
          offset_after = l_offset + 5.

          IF co_debug_mode = 1.
            WRITE: / 'false'  .
          ENDIF.
        ELSE.
          RAISE EXCEPTION TYPE zcx_mdp_json_invalid.
        ENDIF.
      WHEN OTHERS.
        FIND REGEX '\d+' IN SECTION OFFSET l_offset OF json
        MATCH OFFSET l_offset MATCH LENGTH l_len.
        IF co_debug_mode = 1.
          WRITE: / 'number:'  , l_json+l_offset(l_len).
        ENDIF.

        CREATE OBJECT l_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_number.
        l_jsonnode->value = l_json+l_offset(l_len).
        offset_after = l_offset + l_len.
    ENDCASE.

    jsonnode = l_jsonnode.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_MDP_JSON_DESERIALIZER=>DESERIALIZE_OBJECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        STRING
* | [--->] OFFSET_BEFORE                  TYPE        I
* | [<---] JSONNODE                       TYPE REF TO ZCL_MDP_JSON_NODE
* | [<---] OFFSET_AFTER                   TYPE        I
* | [!CX!] ZCX_MDP_JSON_INVALID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deserialize_object.
    DATA l_json TYPE string.
    l_json = json.

    DATA l_offset TYPE i.
    l_offset = offset_before.

    DATA l_len TYPE i.

    DATA : l_object_jsonnode TYPE REF TO zcl_mdp_json_node.
    CREATE OBJECT l_object_jsonnode TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_object.


    IF co_debug_mode = 1.
      WRITE: / 'object:' .
    ENDIF.

    DO.

*  } end
      DATA l_submatch TYPE string.
      FIND REGEX '\A\s*(\}|,)' IN SECTION OFFSET l_offset OF json
             MATCH OFFSET l_offset MATCH LENGTH l_len
             SUBMATCHES l_submatch.
      CASE l_submatch.
        WHEN '}'.
          l_offset = l_offset + l_len .
          offset_after = l_offset.
          EXIT.
        WHEN ','.
          l_offset = l_offset + l_len .
      ENDCASE.

* require a key
      FIND REGEX '\A\s*"([^:]*)"\s*:' IN SECTION OFFSET l_offset OF json
                        MATCH OFFSET l_offset MATCH LENGTH l_len
                        SUBMATCHES l_submatch.
      IF sy-subrc NE 0.
*  ERROR
        RAISE EXCEPTION TYPE zcx_mdp_json_invalid.
      ENDIF.
      IF co_debug_mode = 1.
        WRITE: / 'key:' , l_submatch .
      ENDIF.
      l_offset = l_offset + l_len .

      DATA : l_jsonnode TYPE REF TO zcl_mdp_json_node.

      DATA : wa_object_children TYPE  zcl_mdp_json_node=>typ_object_children .
      wa_object_children-key = l_submatch .

      deserialize_node( EXPORTING json = l_json offset_before = l_offset
       IMPORTING jsonnode = l_jsonnode offset_after = l_offset ).

      wa_object_children-node = l_jsonnode .

      INSERT wa_object_children INTO TABLE l_object_jsonnode->object_children.

      offset_after = l_offset.

    ENDDO.
    jsonnode = l_object_jsonnode .
  ENDMETHOD.
ENDCLASS.