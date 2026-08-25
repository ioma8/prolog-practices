# Prolog Practices

Practice scripts written while learning Prolog (Scryer Prolog / SWI), each with `plunit` tests:

- `csv_bidirectionl.pl` — bidirectional CSV parsing/generation with DCGs
- `datetime_test.pl` — date/time handling
- `strings_test.pl` — string utilities
- `rnt_tsx_checker.pl` — TSX style checker for Raynet-style conventions
- `op_calc_width.pl` — operator precedence / column-width calculations
- `kb2.pl` — small knowledge base

## Run tests

```prolog
?- [csv_bidirectionl].
?- run_tests.
```
