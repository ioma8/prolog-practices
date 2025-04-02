datetime(datetime(Y, M, D, H, Min, S)) -->
    year(Y), [(-)], month(M), [(-)], day(D),
    [ ],
    hour(H), [(:)], minute(Min), [(:)], second(S).

year(Y) -->
    digits(4, Y),
    { Y >= 0 }. % Basic check for non-negative year

month(M) -->
    digits(2, M),
    { M >= 1, M =< 12 }.

day(D) -->
    digits(2, D),
    { D >= 1, D =< 31 }. % Basic check, doesn't account for days per month

hour(H) -->
    digits(2, H),
    { H >= 0, H =< 23 }.

minute(Min) -->
    digits(2, Min),
    { Min >= 0, Min =< 59 }.

second(S) -->
    digits(2, S),
    { S >= 0, S =< 59 }.

digits(N, Value) -->
    number(Value, N, Value).

number(Value, N, Acc) -->
    { N > 0 },
    [DigitCode],
    { code_type(DigitCode, digit),
      Digit is DigitCode - 0',
      NewAcc is Acc * 10 + Digit,
      NewN is N - 1
    },
    number(Value, NewN, NewAcc).
number(Value, 0, Value) --> [].

% Helper predicate to test the datetime parser
validate_datetime(String) :-
    string_codes(String, Codes),
    phrase(datetime(_), Codes),
    writef('%t is a valid datetime.\n', [String]).

validate_datetime(String) :-
    string_codes(String, Codes),
    \+ phrase(datetime(_), Codes),
    writef('%t is not a valid datetime.\n', [String]).