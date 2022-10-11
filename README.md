# TypeCounselor

An experimental library for suggesting type specifications based on Elixir maps
and structures. Useful for finding outdated types in codebases.

```elixir
iex> map_1 = %{identifier: "IBM5100"}
%{identifier: "IBM5100"}

iex> map_2 = %{identifier: 5100}
%{identifier: 5100}

iex> TypeCounselor.suggest([map_1, map_2])
"%{identifier => String.t() | :non_neg_integer}"
```

## Usage

### 1. Installation

Add the package to your `mix.exs`:

```elixir
def deps do
  [
    {:type_counselor, "~> 0.1.0", only: :test}
  ]
end
```

### 2. Instrument the codebase

Manually add `TypeCounselor.add/2` calls to places in the code where structs are
built.

E.g.:

```elixir
def populate_users(user_ids) do
  Enum.map(user_ids, fn user_id ->
    case SpotifyClient.fetch_user(user_id) do
      {:ok, user_info} ->
        %User{
          name: user_info[:username],
          profile: user_info[:profile_url],
          flags: user_info[:flags]
        }

      {:error, _} = result ->
        result
    end
  end)
end
```

When instrumented, it becomes:

```elixir
def populate_users(user_ids) do
  Enum.map(user_ids, fn user_id ->
    case SpotifyClient.fetch_user(user_id) do
      {:ok, user_info} ->
        TypeCounselor.add(:user, %User{
          name: user_info[:username],
          profile: user_info[:profile_url],
          flags: user_info[:flags]
        })

      {:error, _} = result ->
        result
    end
  end)
end
```

### 3. Run tests and collect type suggestions

```shell
# Run tests and spawns iex for collecting type suggestions
$ iex -S mix test

Erlang/OTP 25 [erts-13.0.3] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit:ns]

Compiling 5 files (.ex)
Generated type_counselor app
.......
Finished in 0.01 seconds (0.01s async, 0.00s sync)
7 tests, 0 failures
```

After tests are run, `iex` should be spawned:

```elixir
iex> suggestions = TypeCounselor.fetch(:user)
iex> File.write!("user.exs", suggestions)
```

`user.exs` will have type suggestions for `user` according to `user_info`
content values during test runtime:

```elixir
%{
  name => String.t() | nil,
  profile => String.t(),
  flags => list(:enabled | :disabled)
}
```