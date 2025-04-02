:- use_module(library(readutil)).

% Main function to load and check a file
load_and_check_file :-
    write('Enter the filename: '),
    read_line_to_string(user_input, Filename),
    read_file_to_string(Filename, Content, []),
    validate_file(Content, Filename).

% Validate file and print failing conditions
validate_file(Content, Filename) :-
    findall(Failure, validation_failure(Content, Failure), Failures),
    (   Failures = [] ->
        format('~w is a valid file.~n', [Filename])
    ;   format('~w is not a valid file due to the following issues:~n', [Filename]),
        print_failures(Failures)
    ).

% Print list of failed validations
print_failures([]).
print_failures([F|Fs]) :-
    format('- ~w~n', [F]),
    print_failures(Fs).

% Collect all validation failures
validation_failure(Content, 'Missing initial comment block') :-
    \+ has_initial_comment(Content).
validation_failure(Content, 'Contains TODO comments') :-
    has_todo(Content).
validation_failure(Content, 'Contains debugging statements (debugger)') :-
    contains_substring(Content, 'debugger').
validation_failure(Content, 'Contains print statements (console.log or console.error)') :-
    contains_substring(Content, 'console.').
validation_failure(Content, 'Contains TypeScript ignore directives (@ts-ignore)') :-
    contains_substring(Content, '@ts-ignore').

% Check if the initial comment block exists
has_initial_comment(X) :-
    string_lines(Comment, [
        '/*',
        '* Copyright 2009-2025 RAYNET s.r.o., All rights reserved.',
        '* RAYNET s.r.o. PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.',
        '* www.raynet.cz',
        '*/'
    ]),
    write(Comment),    
    sub_atom(X, 0, _, _, Comment).

% Check for TODO comments
has_todo(X) :-
    contains_substring(X, '// TODO');
    contains_substring(X, '//TODO').

% Check for substring presence
contains_substring(String, Sub) :-
    sub_atom(String, _, _, _, Sub).