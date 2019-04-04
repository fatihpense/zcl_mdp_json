CLASS zcl_mdp_json_node DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: co_json_object TYPE i VALUE 02
               ,co_json_array TYPE i VALUE 03

               ,co_json_string TYPE i VALUE 04
               ,co_json_number TYPE i VALUE 05

               ,co_json_true TYPE i VALUE 06
               ,co_json_false TYPE i VALUE 07
               ,co_json_null TYPE i VALUE 08 .

    TYPES: BEGIN OF typ_object_children,
             key  TYPE string,
             node TYPE REF TO zcl_mdp_json_node,
           END OF typ_object_children,
           BEGIN OF typ_array_children,
             node TYPE REF TO  zcl_mdp_json_node,
           END OF typ_array_children .
    TYPES: tt_object_children TYPE HASHED TABLE OF zcl_mdp_json_node=>typ_object_children WITH UNIQUE KEY key,
           tt_array_children  TYPE TABLE OF zcl_mdp_json_node=>typ_array_children.

    DATA: json_type TYPE i
          ,value TYPE string
          ,object_children TYPE tt_object_children
          ,array_children TYPE tt_array_children .

    METHODS:
      constructor IMPORTING json_type TYPE i,
      object_get_child_node IMPORTING key         TYPE string
                            RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node ,
      array_get_child_node IMPORTING index       TYPE i
                           RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      string_set_value IMPORTING VALUE(value) TYPE string
                       RETURNING VALUE(node)  TYPE REF TO zcl_mdp_json_node ,
      array_add_child_node  IMPORTING child_node        TYPE REF TO zcl_mdp_json_node
                            RETURNING VALUE(array_node) TYPE REF TO zcl_mdp_json_node,
      object_add_child_node IMPORTING child_key          TYPE string
                                      child_node         TYPE REF TO zcl_mdp_json_node
                            RETURNING VALUE(object_node) TYPE REF TO zcl_mdp_json_node,
      serialize RETURNING VALUE(json_string) TYPE string .

    CLASS-METHODS:
      deserialize IMPORTING json        TYPE string
                  RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node
                  RAISING   zcx_mdp_json_invalid ,
      create_node IMPORTING json_type   TYPE i
                  RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_object_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_array_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_string_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_number_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_true_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_false_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node,
      create_null_node RETURNING VALUE(node) TYPE REF TO zcl_mdp_json_node.


  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_MDP_JSON_NODE IMPLEMENTATION.


  METHOD array_add_child_node.

    DATA : wa_array_children TYPE zcl_mdp_json_node=>typ_array_children .

    wa_array_children-node = child_node .

    APPEND wa_array_children TO me->array_children.
    array_node = me.
  ENDMETHOD.


  METHOD array_get_child_node.

	DATA ls_array TYPE typ_array_children.
	READ TABLE me->array_children INTO ls_array INDEX index.
	node = ls_array-node .

  ENDMETHOD.


  METHOD constructor.
    me->json_type = json_type.

  ENDMETHOD.


  METHOD create_array_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_array .
  ENDMETHOD.


  METHOD create_false_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_false .
  ENDMETHOD.


  METHOD create_node.

*    DATA : l_json_node TYPE REF TO zcl_mdp_json_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = json_type .

*    node = l_json_node.
  ENDMETHOD.


  METHOD create_null_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_null .
  ENDMETHOD.


  METHOD create_number_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_number .
  ENDMETHOD.


  METHOD create_object_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_object .
  ENDMETHOD.


  METHOD create_string_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_string .
  ENDMETHOD.


  METHOD create_true_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_true .
  ENDMETHOD.


  METHOD deserialize.
*DATA: l_json_node TYPE REF TO zcl_mdp_json_node.

    zcl_mdp_json_deserializer=>deserialize(
      EXPORTING json = json
      IMPORTING node = node
   ).

  ENDMETHOD.


  METHOD object_add_child_node.

    DATA : wa_array_children TYPE zcl_mdp_json_node=>typ_array_children .

    wa_array_children-node = child_node .

    APPEND wa_array_children TO me->array_children.


    DATA : wa_object_children TYPE  zcl_mdp_json_node=>typ_object_children .
    wa_object_children-key = child_key .

    wa_object_children-node = child_node .

    INSERT wa_object_children INTO TABLE me->object_children.

    object_node = me.


  ENDMETHOD.


  METHOD object_get_child_node.

	DATA ls_object TYPE typ_object_children.
	READ TABLE me->object_children INTO ls_object WITH key key = key.
	node = ls_object-node .

  ENDMETHOD.


  METHOD serialize.

    zcl_mdp_json_serializer=>serialize(
  EXPORTING node = me
  IMPORTING json = json_string ).

  ENDMETHOD.


  METHOD string_set_value.
    me->value = value.
    node = me.
  ENDMETHOD.
ENDCLASS.
