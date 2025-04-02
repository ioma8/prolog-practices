:- module(csv_bidirectional, [parse_csv/2, csv_file_to_terms/2, terms_to_csv_file/2]).

% Import necessary libraries
:- use_module(library(dcg/basics)).  % For DCG utilities
:- use_module(library(plunit)).      % For the testing framework

% Mode indicators in predicate documentation:
% + means the argument should be instantiated (input) when the predicate is called
% - means the argument should be uninstantiated (output) when the predicate is called
% ? means the argument can be either instantiated or not (input or output)
% @ means the argument is input but won't be unified/changed
%
% Examples:
% parse_csv(+CSVChars, -Rows) - CSVChars should be provided, Rows will be the output
% parse_csv(-CSVChars, +Rows) - Rows should be provided, CSVChars will be the output
%
% This parser is bidirectional, so both modes are supported.

% Main predicate for bidirectional CSV parsing
parse_csv(CSV, Rows) :-
    (string(CSV) -> string_chars(CSV, Chars); Chars = CSV),
    phrase(csv(Rows), Chars).

% DCG for parsing a full CSV document
csv([]) --> [].
csv([Row|Rows]) --> row(Row), line_end, csv(Rows).
csv([Row]) --> row(Row).

% DCG for parsing a row
row([Cell|Cells]) --> cell(Cell), (delimiter, row(Cells) ; {Cells = []}).

% DCG for parsing a cell
cell(Cell) --> quoted_string(Cell).
cell(Cell) --> unquoted_string(Cell).

% DCG for parsing a quoted string
quoted_string(String) --> 
    "\"", quoted_chars(Chars), "\"", 
    {atom_chars(String, Chars)}.

% Characters inside quotes - handles escaped quotes
quoted_chars([]) --> [].
quoted_chars([C|Cs]) --> 
    "\"\"", {C = '"'}, quoted_chars(Cs).  % Escaped quote
quoted_chars([C|Cs]) --> 
    [C], {C \= '"'}, quoted_chars(Cs).    % Regular character

% DCG for parsing an unquoted string
unquoted_string(String) --> 
    unquoted_chars(Chars), 
    {atom_chars(String, Chars)}.

% Characters in an unquoted cell
unquoted_chars([]) --> [].
unquoted_chars([C|Cs]) --> 
    [C], {not_delimiter_or_newline(C)}, 
    unquoted_chars(Cs).

% Helper predicate to check if a character is not a delimiter or newline
not_delimiter_or_newline(C) :-
    C \= ';',
    C \= '\n',
    C \= '\r'.

% Recognize CSV delimiter (semicolon)
delimiter --> ";".

% Recognize line endings (both Unix and Windows style)
line_end --> "\r\n".
line_end --> "\n".

% Utility predicate to convert a CSV file to Prolog terms
csv_file_to_terms(File, Terms) :-
    read_file_to_string(File, String, []),
    parse_csv(String, Terms).

% Utility predicate to write Prolog terms to a CSV file
terms_to_csv_file(File, Terms) :-
    phrase(csv(Terms), Chars),
    open(File, write, Stream),
    forall(member(Char, Chars),
           put_char(Stream, Char)),
    close(Stream).

% ======= TESTS =======
:- begin_tests(csv_bidirectional).

% Test basic parsing of CSV into terms
test(parse_basic) :-
    CSV = "a;b;c\nd;e;f",
    parse_csv(CSV, Rows),
    Rows = [[a, b, c], [d, e, f]].

% Test parsing CSV with quoted strings
test(parse_quoted) :-
    CSV = "\"hello\";\"world\"\n\"prolog\";\"csv\"",
    parse_csv(CSV, Rows),
    Rows = [[hello, world], [prolog, csv]].

% Test parsing CSV with escaped quotes within quoted strings
test(parse_escaped_quotes) :-
    CSV = "\"hello\";\"quo\"\"te\"\n\"pro\"\"log\";\"csv\"",
    parse_csv(CSV, Rows),
    Rows = [[hello, 'quo"te'], ['pro"log', csv]].

% Test generating CSV from terms
test(generate_basic) :-
    Rows = [[a, b, c], [d, e, f]],
    parse_csv(Chars, Rows),
    string_chars(GeneratedCSV, Chars),
    GeneratedCSV = "a;b;c\nd;e;f".

% Test generating CSV with quoted strings
test(generate_quoted) :-
    Rows = [[hello, world], [prolog, csv]],
    parse_csv(Chars, Rows),
    % We verify the roundtrip works correctly
    parse_csv(Chars, ParsedRows),
    ParsedRows = Rows.

% Test roundtrip: parse then generate then parse again
test(roundtrip) :-
    OriginalCSV = "a;\"quoted;value\";c\n\"hello,world\";\";\";\"\"\"quoted\"\"\"",
    parse_csv(OriginalCSV, Rows),
    parse_csv(Generated, Rows),
    parse_csv(Generated, RowsAgain),
    Rows = RowsAgain.

% Utility for running all tests
run_csv_tests :-
    run_tests(csv_bidirectional).

% Example of using the utility predicates
% Usage example (uncomment to use):
% 
% % Create a test CSV file
% example_write_csv :-
%     Rows = [[name, age, city], ['John Smith', 30, 'New York'], ['Jane Doe', 25, 'San Francisco']],
%     terms_to_csv_file('/tmp/test.csv', Rows).
% 
% % Read a CSV file
% example_read_csv :-
%     csv_file_to_terms('/tmp/test.csv', Rows),
%     writeln(Rows).

:- end_tests(csv_bidirectional).
