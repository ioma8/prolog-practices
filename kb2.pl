:- use_module(library(dcg/basics)).
:- use_module(library(readutil)).

% Parse file and extract all XML tags
parse_file(Filename, Tags) :-
    read_file_to_string(Filename, Content, []),
    extract_tags(Content, Tags).

% Extract all XML tags from content string
extract_tags(Content, Tags) :-
    split_string(Content, "<", "", Parts),
    extract_tag_parts(Parts, Tags).

% Process each part that came after a "<" character
extract_tag_parts([], []).
extract_tag_parts([_|Parts], Tags) :-
    extract_tag_parts_helper(Parts, Tags).

extract_tag_parts_helper([], []).
extract_tag_parts_helper([Part|Parts], [Tag|Tags]) :-
    split_string(Part, ">", "", [TagContent|_]),
    atomic_list_concat(['<', TagContent, '>'], Tag),
    extract_tag_parts_helper(Parts, Tags).
extract_tag_parts_helper([_|Parts], Tags) :-
    extract_tag_parts_helper(Parts, Tags).

% Run the parser
run :-
    parse_file('/Users/jakubkolcar/projects-rnt/raynetcrm/app/frontend/app/js/React/Components/Message/BulkUpdateMessage.tsx', Tags),
    length(Tags, Count),
    format('Found ~w tags.~n', [Count]),
    writeln(Tags).

% Simple test
test :-
    extract_tags("<div>Hello</div>", Tags),
    writeln(Tags).