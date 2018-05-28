CLASS zcl_mdp_json_serializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: serialize IMPORTING node TYPE REF TO zcl_mdp_json_node EXPORTING json TYPE string  .
  PRIVATE SECTION.
    CLASS-METHODS:
    serialize_node
        IMPORTING jsonnode TYPE REF TO zcl_mdp_json_node
        EXPORTING json TYPE string

   ,serialize_object
        IMPORTING jsonnode TYPE REF TO zcl_mdp_json_node
        EXPORTING json TYPE string

   ,serialize_array
        IMPORTING jsonnode TYPE REF TO zcl_mdp_json_node
        EXPORTING json TYPE string.
*        CHANGING  offset TYPE i .
    CONSTANTS: co_debug_mode TYPE i VALUE 1.

ENDCLASS.



CLASS ZCL_MDP_JSON_SERIALIZER IMPLEMENTATION.


  METHOD serialize.


    serialize_node(
  EXPORTING
    jsonnode = node
  IMPORTING
    json = json
     ) .

    json = json.
  ENDMETHOD.


  METHOD serialize_array.

  ENDMETHOD.


  METHOD serialize_node.
    DATA l_json TYPE string.
    DATA : l_index TYPE i VALUE 0.
    DATA : l_child_json TYPE string.

    CASE    jsonnode->json_type.
      WHEN  zcl_mdp_json_node=>co_json_string.
        CONCATENATE '"' jsonnode->value '"' INTO l_json.
      WHEN zcl_mdp_json_node=>co_json_number.
        l_json = jsonnode->value.
      WHEN zcl_mdp_json_node=>co_json_false.
        l_json = 'false'.
      WHEN zcl_mdp_json_node=>co_json_true.
        l_json = 'true'.
      WHEN zcl_mdp_json_node=>co_json_null.
        l_json = 'null'.
      WHEN zcl_mdp_json_node=>co_json_array.

        DATA : wa_array_children LIKE LINE OF jsonnode->array_children .


        l_json = '['.
        LOOP AT jsonnode->array_children INTO wa_array_children.
          IF l_index > 0.
            CONCATENATE l_json ',' INTO l_json.
          ENDIF.

          serialize_node(
            EXPORTING
              jsonnode = wa_array_children-node
            IMPORTING
              json = l_child_json
          ) .
          CONCATENATE l_json l_child_json INTO l_json.
          CLEAR wa_array_children.
          l_index = 1.
        ENDLOOP.
        CONCATENATE l_json ']' INTO l_json.
      WHEN zcl_mdp_json_node=>co_json_object.
        DATA : wa_object_children LIKE LINE OF jsonnode->object_children .


        l_json = '{'.

        l_index = 0 .
        LOOP AT jsonnode->object_children INTO wa_object_children.
          IF l_index > 0.
            CONCATENATE l_json ',' INTO l_json.
          ENDIF.

          CONCATENATE l_json '"' wa_object_children-key '":' INTO l_json.

          serialize_node(
            EXPORTING
              jsonnode = wa_object_children-node
            IMPORTING
              json = l_child_json
          ) .
          CONCATENATE l_json l_child_json INTO l_json.
          CLEAR wa_array_children.
          l_index = 1.
        ENDLOOP.
        CONCATENATE l_json '}' INTO l_json.
    ENDCASE.

    json = l_json.
  ENDMETHOD.


  METHOD serialize_object.

  ENDMETHOD.
ENDCLASS.
