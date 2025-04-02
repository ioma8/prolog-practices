:- use_module(library(dcg/basics)).
:- use_module(library(readutil)).

% Parse file and extract all XML tags
parse_file(Filename, Tags) :-
    read_file_to_string(Filename, Content, []),
    string_codes(Content, Codes),
    phrase(tags(Tags), Codes).

% DCG for extracting tags: nejprve konzumujeme všechen text až do '<',
% poté načteme tag a rekurzivně pokračujeme; pokud již další '<' nenajdeme,
% prostě ukonzumujeme zbytek textu.
tags([Tag|Tags]) -->
    string_without("<", _),
    "<",
    tag_content(Tag),
    ">",
    !,
    tags(Tags).
tags([]) -->
    string_without("<", _).

tag_content(Tag) -->
    string_without(">", Codes),
    { atom_codes(Atom, Codes),
      atomic_list_concat(['<', Atom, '>'], Tag)
    }.

% Run the parser
run :-
    parse_file('/Users/jakubkolcar/projects-rnt/raynetcrm/app/frontend/app/js/React/Components/Message/BulkUpdateMessage.tsx', Tags),
    length(Tags, Count),
    format('Found ~w tags.~n', [Count]),
    writeln(Tags).

% Simple test – celé vstupní řetězce začínají přímo tagem
test :-
    string_codes("<div>Hello</div>", Codes),
    phrase(tags(Tags), Codes),
    writeln(Tags).

% Simple test – před tagem i po něm je volný text
test2 :-
    string_codes("  dsfkljlk lkj lkj <div>Hello</div> ds asasd asd", Codes),
    phrase(tags(Tags), Codes),
    writeln(Tags).