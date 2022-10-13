# ScheduledMerge

Will attempt to merge Pull Requests with the appropriate labels on a given date

## Development

### Scripts to Rule Them All

- [test](./script/test) will run linters and tests

### Hooks

- [pre-push](.support/hooks/pre-push) - will run pre-push to github.  This will allow for quicker feedback compared to Githb Actions (for now)
  - to use, run `ln -s "$(pwd)/.support/git/hooks/pre-push" "$(pwd)/.git/hooks/pre-push"` from the code root

### GitHub Actions

- [ci.yml](./.github/workflows/ci.yml) will run for every PR

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scheduled_merge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scheduled_merge, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/scheduled_merge>.


an edit to merge
