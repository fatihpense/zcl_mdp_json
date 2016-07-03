*&---------------------------------------------------------------------*
*& Report  ZEXAMPLE_ZCL_MDP_JSON_SERIALIZE_1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZEXAMPLE_ZCL_MDP_JSON_SERIALIZE_1.

DATA: l_string_1 type string.

DATA: l_root_object_node type REF TO zcl_mdp_json_node
      ,l_books_array_node TYPE REF TO zcl_mdp_json_node
      ,l_book_object_node TYPE REF TO zcl_mdp_json_node
      ,l_book_attr_string_node TYPE REF TO zcl_mdp_json_node .

*Create root object
l_root_object_node = zcl_mdp_json_node=>create_object_node( ).

*Create books array
l_books_array_node =  zcl_mdp_json_node=>create_array_node( ).
*add books array to root object with key "books"
l_root_object_node->object_add_child_node( child_key = 'books'  child_node = l_books_array_node ).

*You would probably want to do this in a loop.
*Create book object node
l_book_object_node = zcl_mdp_json_node=>create_object_node( ).
*Add book object to books array
l_books_array_node->array_add_child_node( l_book_object_node ).


l_book_attr_string_node = zcl_mdp_json_node=>create_string_node( ).
l_book_attr_string_node->value = 'Kürk Mantolu Madonna'.
*Add string to book object with key "title_original"
l_book_object_node->object_add_child_node( child_key = 'title_original' child_node = l_book_attr_string_node ).

l_string_1 = l_root_object_node->serialize( ).



DATA: l_string_2 type string.
*DATA: l_root_object_node_2 type zcl_mdp_json_node.

*Create same JSON object with one dot(.) and without data definitions using chaining.
l_string_2 = zcl_mdp_json_node=>create_object_node(
)->object_add_child_node( child_key = 'books' child_node = zcl_mdp_json_node=>create_array_node(
  )->array_add_child_node( child_node = zcl_mdp_json_node=>create_object_node(
    )->object_add_child_node( child_key = 'title_original' child_node = zcl_mdp_json_node=>create_string_node(
      )->string_set_value( value = 'Kürk Mantolu Madonna' )
    )
  )
)->serialize( ).




START-OF-SELECTION.

WRITE: / 'string 1: ' , l_string_1.

WRITE: / 'string 2: ' , l_string_2.