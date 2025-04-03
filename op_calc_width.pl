:- use_module(library(clpfd)).


total_width(Strs, TotalWidth) :-
	maplist(str_width, Strs, Lens),
	sum_list(Lens, StringsWidth),
	length(Strs, Count),
	paddings(Count, Paddings),
	gaps(Count, Gaps),
	TotalWidth #= StringsWidth + Paddings + Gaps.

total_width_with_collapsed(Strs, TotalWidth) :-
	total_width(Strs, Width),
	gaps(1, ExtraGap),
	TotalWidth #= Width + 32 + ExtraGap.

str_len(Str, X) :-
	length(Str, X).

str_width(Str, Width) :-
	str_len(Str, StrLen),
	Width #= StrLen*7.

paddings(Count, Paddings) :-
	Padding #= 74,
	Paddings #= Count*Padding.

gaps(Count, Gaps) :-
	Gap #= 3,
	Gaps #= (Count - 1)*Gap.