defmodule Tock.Server do
  @moduledoc false

  use GenServer

  @type expectation_t ::
          { { module, atom, non_neg_integer }, [{ :expect | :stub, function }] }

  #
  # client
  #

  @spec join(pid) :: pid
  def join(tock) do
    GenServer.call(tock, :join)
  end

  @spec put_expectation(pid, expectation_t) :: pid
  def put_expectation(tock, expectation) do
    GenServer.call(tock, { :put_expectation, expectation })
  end

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, name: opts[:name])
  end

  #
  # callbacks
  #

  @impl true
  def init(:ok) do
    { :ok, %{ expectations: %{}, results: %{} } }
  end

  @impl true
  def handle_call(:join, { owner, _ref }, state) do
    Process.monitor(owner)

    state = put_in(state, [:expectations, owner], %{})

    { :reply, self(), state }
  end

  @impl true
  def handle_call({ :put_expectation, { signature, expects } }, { owner, _ref }, state) do
    expectations = get_in(state, [:expectations, owner, signature]) || []
    expectations = Enum.reject(expectations, fn({ type, _ }) -> :stub == type end)
    expectations = expectations ++ expects

    state = put_in(state, [:expectations, owner, signature], expectations)

    { :reply, self(), state }
  end

  @impl true
  def handle_call({ :start_task, [_, _, _, { module, fun, args }], _, _ }, { owner, _ref }, state) do
    signature = { module, fun, length(args) }

    state =
      case get_in(state, [:expectations, owner, signature]) || [] do
        [{ :expect, code } | t] ->
          state
          |> put_in([:expectations, owner, signature], t)
          |> put_in([:results, owner], apply(code, args))
        [{ :stub, code } | _t] ->
          put_in(state, [:results, owner], apply(code, args))
        [] ->
          state
      end

    { :reply, { :ok, self() }, state }
  end

  @impl true
  def handle_info({ :DOWN, _ref, :process, owner, _reason }, state) do
    state = update_in(state, [:expectations], &(Map.delete(&1, owner)))

    { :noreply, state }
  end

  @impl true
  def handle_info({ owner, ref }, state) do
    result = get_in(state, [:results, owner])

    if result, do: send(owner, { ref, result })

    state = update_in(state, [:results], &(Map.delete(&1, owner)))

    { :noreply, state }
  end
end
