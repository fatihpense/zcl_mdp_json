*&---------------------------------------------------------------------*
*& Report  ZEXAMPLE_ZCL_MDP_JSON_PERF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zexample_zcl_mdp_json_perf.

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
SEPARATED BY cl_abap_char_utilities=>newline .


DATA: l_ts_start TYPE timestampl.
DATA: l_ts_end TYPE timestampl.
DATA: l_ts_diff TYPE tzntstmpl.

DATA: l_jsonnode TYPE REF TO zcl_mdp_json_node.

GET TIME STAMP FIELD l_ts_start.

DO 10000 TIMES.
  zcl_mdp_json_deserializer=>deserialize(
    EXPORTING json = l_json_string
    IMPORTING node = l_jsonnode ).

  zcl_mdp_json_serializer=>serialize(
    EXPORTING node = l_jsonnode
    IMPORTING json = l_json_string ).
ENDDO.

GET TIME STAMP FIELD l_ts_end.



CALL METHOD cl_abap_tstmp=>subtract
  EXPORTING
    tstmp1 = l_ts_start
    tstmp2 = l_ts_end
  RECEIVING
    r_secs = l_ts_diff.

START-OF-SELECTION.
  WRITE: 'Time for 10000 serialization & deserialization: ' , l_ts_diff.
