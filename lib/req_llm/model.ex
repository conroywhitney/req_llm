defmodule ReqLLM.Model do
  @moduledoc """
  Compatibility shim - wraps LLMDB.Model for jido_ai compatibility.

  ReqLLM v1.2.0 uses LLMDB.Model directly, but jido_ai expects ReqLLM.Model.
  This module provides the expected interface by wrapping LLMDB.Spec.resolve/1.
  """

  @doc """
  Create a model from a spec string or tuple.

  ## Examples

      iex> ReqLLM.Model.from("anthropic:claude-3-5-sonnet")
      {:ok, %LLMDB.Model{...}}

      iex> ReqLLM.Model.from({:anthropic, "claude-3-5-sonnet", []})
      {:ok, %LLMDB.Model{...}}
  """
  def from(spec) when is_binary(spec) do
    case LLMDB.Spec.resolve(spec) do
      {:ok, {_provider, _model_id, model}} -> {:ok, model}
      {:error, reason} -> {:error, reason}
    end
  end

  def from({provider, model_id}) when is_atom(provider) and is_binary(model_id) do
    case LLMDB.Spec.resolve({provider, model_id}) do
      {:ok, {_provider, _model_id, model}} -> {:ok, model}
      {:error, reason} -> {:error, reason}
    end
  end

  def from({provider, model_id, _opts}) when is_atom(provider) and is_binary(model_id) do
    # Ignore opts for now, just resolve the model
    case LLMDB.Spec.resolve({provider, model_id}) do
      {:ok, {_provider, _model_id, model}} -> {:ok, model}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Create a new model struct from provider and model name"
  def new(provider, model_name) when is_atom(provider) and is_binary(model_name) do
    # Try to resolve from catalog first, fall back to minimal struct
    case LLMDB.Spec.resolve({provider, model_name}) do
      {:ok, {_provider, _model_id, model}} ->
        model

      {:error, _reason} ->
        # Create minimal model struct if not in catalog
        LLMDB.Model.new!(%{id: model_name, provider: provider})
    end
  end

  @doc "Get model by spec string"
  def get(spec) when is_binary(spec) do
    from(spec)
  end

  # Type alias for documentation
  @type t :: LLMDB.Model.t()
end
