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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->ARRAY_ADD_CHILD_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] CHILD_NODE                     TYPE REF TO ZCL_MDP_JSON_NODE
* | [<-()] ARRAY_NODE                     TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD array_add_child_node.

    DATA : wa_array_children TYPE zcl_mdp_json_node=>typ_array_children .

    wa_array_children-node = child_node .

    APPEND wa_array_children TO me->array_children.
    array_node = me.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->ARRAY_GET_CHILD_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] INDEX                          TYPE        I
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD array_get_child_node.

    node = me->array_children[  index  ]-node .

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON_TYPE                      TYPE        I
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.
    me->json_type = json_type.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_ARRAY_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_array_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_array .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_FALSE_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_false_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_false .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON_TYPE                      TYPE        I
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_node.

*    DATA : l_json_node TYPE REF TO zcl_mdp_json_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = json_type .

*    node = l_json_node.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_NULL_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_null_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_null .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_NUMBER_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_number_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_number .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_OBJECT_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_object_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_object .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_STRING_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_string_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_string .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>CREATE_TRUE_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_true_node.
    CREATE OBJECT node TYPE zcl_mdp_json_node EXPORTING json_type = zcl_mdp_json_node=>co_json_true .
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_MDP_JSON_NODE=>DESERIALIZE
* +-------------------------------------------------------------------------------------------------+
* | [--->] JSON                           TYPE        STRING
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* | [!CX!] ZCX_MDP_JSON_INVALID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD deserialize.
*DATA: l_json_node TYPE REF TO zcl_mdp_json_node.

    zcl_mdp_json_deserializer=>deserialize(
      EXPORTING json = json
      IMPORTING node = node
   ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->OBJECT_ADD_CHILD_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] CHILD_KEY                      TYPE        STRING
* | [--->] CHILD_NODE                     TYPE REF TO ZCL_MDP_JSON_NODE
* | [<-()] OBJECT_NODE                    TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->OBJECT_GET_CHILD_NODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] KEY                            TYPE        STRING
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD object_get_child_node.

    node = me->object_children[ key = key  ]-node .

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->SERIALIZE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] JSON_STRING                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD serialize.

    zcl_mdp_json_serializer=>serialize(
  EXPORTING node = me
  IMPORTING json = json_string ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_MDP_JSON_NODE->STRING_SET_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] VALUE                          TYPE        STRING
* | [<-()] NODE                           TYPE REF TO ZCL_MDP_JSON_NODE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD string_set_value.
    me->value = value.
    node = me.
  ENDMETHOD.
ENDCLASS.