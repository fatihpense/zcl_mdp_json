*&---------------------------------------------------------------------*
*& Report  ZEXAMPLE_ZCL_MDP_JSON_DESERIALIZE_1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zexample_zcl_mdp_json_deserialize_1.

DATA:  l_json_string TYPE string.
CONCATENATE

'{'
'  "books": ['
'    {'
'      "title_original": "Kürk Mantolu Madonna",'
'      "title_english": "Madonna in a Fur Coat",'
'      "author": "Sabahattin Ali",'
'      "quote_english": "It is, perhaps, easier to dismiss a man whose face gives no indication of an inner life. And what a pity that is: a dash of curiosity is all it takes to stumble upon treasures we never expected.",'
'      "original_language": "tr"'
'    },'
'    {'
'      "title_original": "Записки из подполья",'
'      "title_english": "Notes from Underground",'
'      "author": "Fyodor Dostoyevsky",'
'      "quote_english": "I am alone, I thought, and they are everybody.",'
'      "original_language": "ru"'
'    },'
'    {'
'      "title_original": "Die Leiden des jungen Werthers",'
'      "title_english": "The Sorrows of Young Werther",'
'      "author": "Johann Wolfgang von Goethe",'
'      "quote_english": "The human race is a monotonous affair. Most people spend the greatest part of their time working in order to live, and what little freedom remains so fills them with fear that they seek out any and every means to be rid of it.",'
'      "original_language": "de"'
'    },'
'    {'
'      "title_original": "The Call of the Wild",'
'      "title_english": "The Call of the Wild",'
'      "author": "Jack London",'
'      "quote_english": "A man with a club is a law-maker, a man to be obeyed, but not necessarily conciliated.",'
'      "original_language": "en"'
'    }'
'  ]'
'}'

INTO l_json_string
SEPARATED BY cl_abap_char_utilities=>cr_lf .




DATA: l_json_root_object TYPE REF TO zcl_mdp_json_node.

l_json_root_object = zcl_mdp_json_node=>deserialize( json = l_json_string ).

DATA: l_string TYPE string.

l_string = l_json_root_object->object_get_child_node( key = 'books'
)->array_get_child_node( index = 1
)->object_get_child_node( key = 'quote_english' )->value.

START-OF-SELECTION.

  WRITE: 'Quote from the first book: ', l_string .
