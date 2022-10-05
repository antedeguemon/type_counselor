# TypeCounselor

An experimental library for suggesting type specifications based on Elixir maps
and structures.

```elixir
iex> TypeCounselor.suggest([%{identifier: "IBM5100"}, %{identifier: 5100}])
"%{identifier => String.t() | :non_neg_integer}"
```

## Usage

### 1. Installation

Add the package to your `mix.exs`:

```elixir
def deps do
  [
    {:type_counselor, "~> 0.1.0"}
  ]
end
```

### 2. Instrument the codebase

Manually instrument places where structs are created to call `TypeCounselor.add/2`.

Example:

```elixir
def populate_users(user_ids) do
  Enum.map(user_ids, fn user_id -> 
    case SpotifyClient.fetch_user(user_id) do
      {:ok, user_info} ->
        # Note the `TypeCounselor.add/2` call below
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

The content of the created `user.exs` will contain type suggestions for `user`
according to `user_info` content values during test runtime:

```elixir
%{
  name => String.t() | nil,
  profile => String.t(),
  flags => list(:enabled | :disabled)
}
```