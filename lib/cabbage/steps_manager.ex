defmodule Cabbage.StepsManager do
  @moduledoc """
  Steps related helper.
  """

  alias Cabbage.{Executor, MissingStepError, Step}

  @doc """
  Execute first matching step callback
  """
  def execute(step, state, steps_callbacks) do
    case Executor.execute_first_matching_callback(step, state, steps_callbacks) do
      {:error, :no_match} -> raise MissingStepError, step: step
      {:ok, response} -> response
    end
  end

  @doc """
  Can step callback handle feature step?
  """
  def handles_step?({type, regex}, %Step{text: text, type: type}), do: Regex.match?(regex, text)
  def handles_step?(_, _), do: false

  @doc """
  Extract parameters from feature step and prepare for execution
  """
  def extract_parameters(regex, %{text: text, table_data: table, doc_string: doc_string, parameters: parameters}) do
    regex
    |> Regex.named_captures(text)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> Map.put(:table, table)
    |> Map.put(:doc_string, doc_string)
    |> Map.merge(parameters)
  end
end