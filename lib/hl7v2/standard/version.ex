defmodule HL7v2.Standard.Version do
  @moduledoc """
  HL7 v2.x version utilities.

  Pure helpers for normalizing, comparing, and gating on HL7 version strings.

  This module is intentionally lightweight and side-effect free. It is the
  foundation for future version-aware validation rules — callers can use it
  today to detect, normalize, and compare versions, even though no validation
  rule yet branches on version.

  ## Supported range

  The library targets HL7 v2.3 through v2.8 inclusive. `supported?/1` returns
  `true` for any canonical version that falls within that range.

  ## Examples

      iex> HL7v2.Standard.Version.normalize("v2.5.1")
      "2.5.1"

      iex> HL7v2.Standard.Version.compare("2.5", "2.7")
      :lt

      iex> HL7v2.Standard.Version.at_least?("2.7", "2.5")
      true

      iex> HL7v2.Standard.Version.supported?("2.5.1")
      true

  """

  @supported_majors [2]
  @supported_minor_min 3
  @supported_minor_max 8

  @doc """
  Normalizes an HL7 version string to its canonical form.

  Strips an optional `v`/`V` prefix and surrounding whitespace, and validates
  that the result looks like a dotted numeric version (e.g. `2`, `2.5`,
  `2.5.1`). Returns the canonical string on success, or `nil` for `nil`,
  empty, or unrecognized inputs.

  ## Examples

      iex> HL7v2.Standard.Version.normalize("2.5.1")
      "2.5.1"

      iex> HL7v2.Standard.Version.normalize("v2.7")
      "2.7"

      iex> HL7v2.Standard.Version.normalize("  V2.5  ")
      "2.5"

      iex> HL7v2.Standard.Version.normalize(nil)
      nil

      iex> HL7v2.Standard.Version.normalize("garbage")
      nil

  """
  @spec normalize(binary() | nil) :: binary() | nil
  def normalize(nil), do: nil

  def normalize(value) when is_binary(value) do
    trimmed =
      value
      |> String.trim()
      |> strip_v_prefix()

    case parse_parts(trimmed) do
      [] -> nil
      parts -> Enum.join(parts, ".")
    end
  end

  def normalize(_), do: nil

  @doc """
  Compares two HL7 version strings, returning `:lt`, `:eq`, or `:gt`.

  Inputs are normalized first via `normalize/1`. Missing trailing components
  are treated as `0`, so `"2.5"` and `"2.5.0"` compare equal.

  Raises `ArgumentError` if either input is not a recognizable version.

  ## Examples

      iex> HL7v2.Standard.Version.compare("2.5", "2.7")
      :lt

      iex> HL7v2.Standard.Version.compare("2.7", "2.5.1")
      :gt

      iex> HL7v2.Standard.Version.compare("2.5", "2.5.0")
      :eq

      iex> HL7v2.Standard.Version.compare("v2.5.1", "2.5.1")
      :eq

  """
  @spec compare(binary(), binary()) :: :lt | :eq | :gt
  def compare(a, b) do
    do_compare(to_tuple!(a), to_tuple!(b))
  end

  @doc """
  Returns `true` when `version` is greater than or equal to `target`.

  ## Examples

      iex> HL7v2.Standard.Version.at_least?("2.7", "2.5")
      true

      iex> HL7v2.Standard.Version.at_least?("2.5.1", "2.5.1")
      true

      iex> HL7v2.Standard.Version.at_least?("2.5", "2.7")
      false

  """
  @spec at_least?(binary(), binary()) :: boolean()
  def at_least?(version, target) do
    compare(version, target) != :lt
  end

  @doc """
  Returns `true` when the given version is within the library's supported
  range (HL7 v2.3 through v2.8 inclusive).

  Inputs are normalized first. Unparseable, missing, or out-of-range versions
  return `false`.

  ## Examples

      iex> HL7v2.Standard.Version.supported?("2.5.1")
      true

      iex> HL7v2.Standard.Version.supported?("2.3")
      true

      iex> HL7v2.Standard.Version.supported?("2.8")
      true

      iex> HL7v2.Standard.Version.supported?("2.2")
      false

      iex> HL7v2.Standard.Version.supported?("3.0")
      false

      iex> HL7v2.Standard.Version.supported?(nil)
      false

  """
  @spec supported?(binary() | nil) :: boolean()
  def supported?(version) do
    case to_tuple(version) do
      {:ok, {major, minor, _patch}} ->
        major in @supported_majors and minor >= @supported_minor_min and
          minor <= @supported_minor_max

      :error ->
        false
    end
  end

  # -- Internals --

  defp strip_v_prefix(<<v, rest::binary>>) when v in [?v, ?V], do: String.trim_leading(rest)
  defp strip_v_prefix(other), do: other

  defp parse_parts(""), do: []

  defp parse_parts(string) do
    parts = String.split(string, ".")

    if Enum.all?(parts, &numeric?/1) do
      parts
    else
      []
    end
  end

  defp numeric?(""), do: false
  defp numeric?(part), do: String.match?(part, ~r/^\d+$/)

  defp to_tuple(version) do
    case normalize(version) do
      nil ->
        :error

      canonical ->
        parts =
          canonical
          |> String.split(".")
          |> Enum.map(&String.to_integer/1)

        {:ok, pad_tuple(parts)}
    end
  end

  defp to_tuple!(version) do
    case to_tuple(version) do
      {:ok, tuple} -> tuple
      :error -> raise ArgumentError, "invalid HL7 version: #{inspect(version)}"
    end
  end

  defp pad_tuple([major]), do: {major, 0, 0}
  defp pad_tuple([major, minor]), do: {major, minor, 0}
  defp pad_tuple([major, minor, patch | _]), do: {major, minor, patch}

  defp do_compare(same, same), do: :eq

  defp do_compare({a1, a2, a3}, {b1, b2, b3}) do
    cond do
      a1 < b1 -> :lt
      a1 > b1 -> :gt
      a2 < b2 -> :lt
      a2 > b2 -> :gt
      a3 < b3 -> :lt
      a3 > b3 -> :gt
      true -> :eq
    end
  end
end
