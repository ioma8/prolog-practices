% "string" - stringy se po pomojem setupu: :- set_prolog_flag(double_quotes, chars).
% v dvojitych uzovkach se bere jako seznam atomu (1 znak = 1 atom)

% first_char([Ch|Chs], Ch). - nevyuzita promenna nakonec nahrazena za _ aby to nehlasilo varovani
% o nevyuzite promenne 

first_char([Ch|_], Ch).

% ==========

:- use_module(library(dcg/basics)).  % for `string_without/3`, etc.

% Parse a CSV line: one or more fields separated by ;
csv_line([Field|Rest]) --> field(Field), fields(Rest).
csv_line([]) --> [].

% More fields follow after a semicolon
fields([Field|Rest]) --> ";", field(Field), fields(Rest).
fields([]) --> [].

% A field is a sequence of characters that are not ;
field([C|Cs]) --> [C], { C \= ';' }, field(Cs).
field([]) --> [].

% moje wrapper metoda pro parsovani CSV radky
csv_line_fields(CsvLine, Fields) :-
    phrase(csv_line(Fields), CsvLine).

csv_lines([CsvLine|Rest]) --> csv_line(CsvLine), "\n", csv_lines(Rest).
csv_lines([CsvLine]) --> csv_line(CsvLine), "\n".
csv_lines([]) --> [].

% moje wrapper metoda pro parsovani CSV souboru kompletniho kk
csv_lines_fields(CsvLines, Fields) :-
    phrase(csv_lines(Fields), CsvLines).

%%%% JSON PARSER %%%%

myjson_object([Field|Rest]) --> "{", myjson_fields([Field|Rest]), "}".

myjson_fields([Field|Rest]) --> myjson_field(Field), ",", myjson_fields(Rest).
myjson_fields([Field]) --> myjson_field(Field).

myjson_field([Key, Value]) --> myjson_key(Key), ":", myjson_value(Value).

myjson_key([C|Cs]) --> [C], { C \= ':' }, myjson_key(Cs).
myjson_key([]) --> [].

myjson_value([C|Cs]) --> [C], { C \= ',' }, myjson_value(Cs).
myjson_value([]) --> [].

myjson_object_fields(JsonObject, Fields) :-
    phrase(myjson_object(Fields), JsonObject).