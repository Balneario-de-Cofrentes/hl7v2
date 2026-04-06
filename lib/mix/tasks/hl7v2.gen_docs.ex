defmodule Mix.Tasks.Hl7v2.GenDocs do
  @moduledoc """
  Generates reference documentation from code metadata.

  Produces three files under `docs/reference/`:

  - `message-structures.md` -- all 222 message structures grouped by family
  - `segments.md` -- all 152 segments with field definitions
  - `data-types.md` -- all 90 data types with component definitions

  ## Usage

      mix hl7v2.gen_docs

  """

  use Mix.Task

  @shortdoc "Generate reference docs from code metadata"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    docs_dir = Path.join(File.cwd!(), "docs/reference")
    File.mkdir_p!(docs_dir)

    generate_message_structures(docs_dir)
    generate_segments(docs_dir)
    generate_data_types(docs_dir)
  end

  # ---------------------------------------------------------------------------
  # Message Structures
  # ---------------------------------------------------------------------------

  defp generate_message_structures(docs_dir) do
    structures = load_all_structures()
    event_map = build_event_map()
    families = group_by_family(structures)

    lines =
      [header_message_structures(), notation_section()] ++
        Enum.flat_map(families, fn {family, structs} ->
          ["\n## #{family}\n"] ++
            Enum.flat_map(structs, fn {name, defn} ->
              render_structure(name, defn, event_map)
            end)
        end) ++
        [sharing_summary(event_map, structures), segment_names_table(structures)]

    path = Path.join(docs_dir, "message-structures.md")
    File.write!(path, Enum.join(lines, "\n"))
    Mix.shell().info("Generated #{path} (#{map_size(structures)} structures)")
  end

  defp header_message_structures do
    """
    # HL7 v2.5.1 Message Structure Reference

    Complete segment structure definitions for all #{HL7v2.Standard.MessageStructure.count()} message
    structures in the HL7 v2.5.1 standard as implemented by this library.

    **Generated from code metadata** -- do not edit by hand.
    Run `mix hl7v2.gen_docs` to regenerate.
    """
  end

  defp notation_section do
    """
    ## Notation

    | Symbol | Meaning |
    |--------|---------|
    | `MSH` | Required segment (bold in tree) |
    | `[SFT]` | Optional segment |
    | `*` | Repeating (0..* or 1..*) |
    | `GROUP { ... }` | Named segment group |
    | `[GROUP] { ... }` | Optional group |
    | Indentation | Nesting depth within groups |
    """
  end

  defp load_all_structures do
    HL7v2.Standard.MessageStructure.names()
    |> Enum.map(fn name -> {name, HL7v2.Standard.MessageStructure.get(name)} end)
    |> Enum.into(%{})
  end

  defp build_event_map do
    # Build reverse map: structure_name => [{code, event}, ...]
    canonical_structures()
    |> Enum.group_by(fn {_key, structure} -> structure end, fn {{code, event}, _} ->
      "#{code}^#{event}"
    end)
    |> Enum.map(fn {struct, events} -> {struct, Enum.sort(events)} end)
    |> Enum.into(%{})
  end

  defp canonical_structures do
    # We need to reconstruct the canonical_structures map by probing known events.
    # Since the map is private in MessageDefinition, we probe all known codes+events.
    all_codes_events()
    |> Enum.map(fn {code, event} ->
      structure = HL7v2.MessageDefinition.canonical_structure(code, event)
      {{code, event}, structure}
    end)
    |> Enum.reject(fn {{code, event}, structure} ->
      # Filter out fallback mappings (CODE_EVENT) that don't have actual structures
      structure == "#{code}_#{event}" and
        HL7v2.Standard.MessageStructure.get(structure) == nil
    end)
  end

  # All known {code, event} pairs from the canonical_structures map.
  # Extracted from HL7v2.MessageDefinition source.
  defp all_codes_events do
    adt_events =
      for e <-
            ~w(A01 A02 A03 A04 A05 A06 A07 A08 A09 A10 A11 A12 A13 A14 A15 A16 A17 A18 A19 A20 A21 A22 A23 A24 A25 A26 A27 A28 A29 A30 A31 A32 A33 A34 A35 A36 A37 A38 A39 A40 A41 A42 A43 A44 A45 A46 A47 A48 A49 A50 A51 A52 A53 A54 A55 A56 A57 A60 A61 A62),
          do: {"ADT", e}

    bar_events = for e <- ~w(P01 P02 P05 P06 P10 P12), do: {"BAR", e}

    blood_events =
      [{"BPS", "O29"}, {"BRP", "O30"}, {"BRT", "O32"}, {"BTS", "O31"}]

    crm_events = for e <- ~w(C01 C02 C03 C04 C05 C06 C07 C08), do: {"CRM", e}
    csu_events = for e <- ~w(C09 C10 C11 C12), do: {"CSU", e}
    dft_events = [{"DFT", "P03"}, {"DFT", "P11"}]
    doc_events = [{"DOC", "T12"}]

    equip_events = [
      {"EAC", "U07"},
      {"EAR", "U08"},
      {"ESR", "U02"},
      {"ESU", "U01"},
      {"INR", "U06"},
      {"INU", "U05"},
      {"LSU", "U12"},
      {"SSR", "U04"},
      {"SSU", "U03"},
      {"TCU", "U10"},
      {"EAN", "U09"}
    ]

    mdm_events = for e <- ~w(T01 T02 T03 T04 T05 T06 T07 T08 T09 T10 T11), do: {"MDM", e}

    mfk_events = for e <- ~w(M01 M02 M03 M04 M05 M06 M07 M08 M09 M10 M11 M12 M13), do: {"MFK", e}

    mfn_events =
      for e <- ~w(M01 M02 M03 M04 M05 M06 M07 M08 M09 M10 M11 M12 M13 M15),
          do: {"MFN", e}

    mfq_events = [{"MFQ", "M01"}]

    mfr_events =
      for e <- ~w(M01 M04 M05 M06 M07), do: {"MFR", e}

    nmd_events = [{"NMD", "N02"}, {"NMQ", "N01"}, {"NMR", "N01"}]

    order_events = [
      {"OMB", "O27"},
      {"OMD", "O03"},
      {"OMG", "O19"},
      {"OMI", "O23"},
      {"OML", "O21"},
      {"OML", "O33"},
      {"OML", "O35"},
      {"OML", "O39"},
      {"OMN", "O07"},
      {"OMP", "O09"},
      {"OMS", "O05"},
      {"ORA", "R33"},
      {"ORA", "R41"},
      {"ORB", "O28"},
      {"ORD", "O04"},
      {"ORG", "O20"},
      {"ORI", "O24"},
      {"ORL", "O22"},
      {"ORL", "O34"},
      {"ORL", "O36"},
      {"ORL", "O40"},
      {"ORM", "O01"},
      {"ORN", "O08"},
      {"ORP", "O10"},
      {"ORR", "O02"},
      {"ORS", "O06"},
      {"ORU", "R01"},
      {"ORU", "R30"},
      {"ORU", "R31"},
      {"ORU", "R32"},
      {"OUL", "R21"},
      {"OUL", "R22"},
      {"OUL", "R23"},
      {"OUL", "R24"},
      {"ORF", "R04"}
    ]

    pgl_events = for e <- ~w(PC6 PC7 PC8), do: {"PGL", e}
    ppg_events = for e <- ~w(PCG PCH PCJ), do: {"PPG", e}
    ppp_events = for e <- ~w(PCB PCC PCD), do: {"PPP", e}
    ppr_events = for e <- ~w(PC1 PC2 PC3), do: {"PPR", e}
    ppt_events = [{"PPT", "PCL"}]
    ppv_events = [{"PPV", "PCA"}]
    prr_events = [{"PRR", "PC5"}]
    ptr_events = [{"PTR", "PCF"}]

    pex_events = [{"PEX", "P07"}, {"PEX", "P08"}, {"SUR", "P09"}]

    pmu_events = for e <- ~w(B01 B02 B03 B04 B05 B06 B07 B08), do: {"PMU", e}

    query_events = [
      {"QBP", "Q11"},
      {"QBP", "Q13"},
      {"QBP", "Q15"},
      {"QBP", "Q21"},
      {"QBP", "Q22"},
      {"QBP", "Q23"},
      {"QBP", "Q24"},
      {"QBP", "Q25"},
      {"QBP", "Z73"},
      {"QCK", "Q02"},
      {"QCN", "J01"},
      {"QSB", "Q16"},
      {"QVR", "Q17"},
      {"RDY", "K15"},
      {"RSP", "K11"},
      {"RSP", "K13"},
      {"RSP", "K15"},
      {"RSP", "K21"},
      {"RSP", "K22"},
      {"RSP", "K31"},
      {"RSP", "Q11"},
      {"RSP", "K23"},
      {"RSP", "K24"},
      {"RSP", "K25"},
      {"RSP", "Z82"},
      {"RSP", "Z86"},
      {"RSP", "Z88"},
      {"RSP", "Z90"},
      {"RTB", "K13"},
      {"RTB", "Z74"}
    ]

    pharmacy_query_events = [
      {"RAR", "RAR"},
      {"RDR", "RDR"},
      {"RER", "RER"},
      {"ROR", "ROR"},
      {"RGR", "RGR"}
    ]

    pharmacy_events = [
      {"RAS", "O17"},
      {"RDE", "O11"},
      {"RDS", "O13"},
      {"RGV", "O15"},
      {"RRA", "O18"},
      {"RRD", "O14"},
      {"RRE", "O12"},
      {"RRG", "O16"}
    ]

    referral_events =
      for(e <- ~w(I12 I13 I14 I15), do: {"REF", e}) ++
        for e <- ~w(I12 I13 I14 I15), do: {"RRI", e}

    siu_events =
      for e <- ~w(S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S26), do: {"SIU", e}

    srm_events = for e <- ~w(S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11), do: {"SRM", e}
    srr_events = for e <- ~w(S01 S02 S03 S04 S05 S06 S07 S08 S09 S10 S11), do: {"SRR", e}

    patient_info_events = [
      {"QRY", "A19"},
      {"RCI", "I05"},
      {"RPA", "I08"},
      {"RPA", "I09"},
      {"RPA", "I10"},
      {"RPA", "I11"},
      {"RPI", "I01"},
      {"RPI", "I04"},
      {"RPL", "I02"},
      {"RPR", "I03"},
      {"RQA", "I08"},
      {"RQA", "I09"},
      {"RQA", "I10"},
      {"RQA", "I11"},
      {"RQC", "I05"},
      {"RQC", "I06"},
      {"RQI", "I01"},
      {"RQI", "I02"},
      {"RQI", "I03"},
      {"RQP", "I04"},
      {"RCL", "I06"}
    ]

    collab_events = [
      {"CCR", "I16"},
      {"CCR", "I17"},
      {"CCR", "I18"},
      {"CCI", "I22"},
      {"CCU", "I20"},
      {"CCU", "I21"},
      {"CCQ", "I19"},
      {"CCF", "I22"}
    ]

    ehc_events =
      for e <- ~w(E01 E02 E04 E10 E12 E13 E15 E20 E21 E24), do: {"EHC", e}

    legacy_query_events = [
      {"QRY", "Q01"},
      {"QRY", "Q02"},
      {"QRY", "R02"},
      {"QRY", "PC4"},
      {"QRY", "PC5"},
      {"QRY", "PC9"},
      {"QRY", "PCE"},
      {"QRY", "PCK"},
      {"OSQ", "Q06"},
      {"OSR", "Q06"}
    ]

    scheduling_query_events = [{"SQM", "S25"}, {"SQR", "S25"}]

    misc_events = [
      {"UDM", "Q05"},
      {"VXQ", "V01"},
      {"VXR", "V03"},
      {"VXU", "V04"},
      {"VXX", "V02"}
    ]

    adt_events ++
      bar_events ++
      blood_events ++
      crm_events ++
      csu_events ++
      dft_events ++
      doc_events ++
      equip_events ++
      mdm_events ++
      mfk_events ++
      mfn_events ++
      mfq_events ++
      mfr_events ++
      nmd_events ++
      order_events ++
      pgl_events ++
      ppg_events ++
      ppp_events ++
      ppr_events ++
      ppt_events ++
      ppv_events ++
      prr_events ++
      ptr_events ++
      pex_events ++
      pmu_events ++
      query_events ++
      pharmacy_query_events ++
      pharmacy_events ++
      referral_events ++
      siu_events ++
      srm_events ++
      srr_events ++
      patient_info_events ++
      collab_events ++
      ehc_events ++
      legacy_query_events ++
      scheduling_query_events ++
      misc_events
  end

  defp group_by_family(structures) do
    structures
    |> Enum.sort_by(fn {name, _} -> name end)
    |> Enum.group_by(fn {name, _} ->
      name |> String.split("_") |> hd()
    end)
    |> Enum.sort_by(fn {family, _} -> family end)
  end

  defp render_structure(name, %{description: desc, nodes: nodes}, event_map) do
    events = Map.get(event_map, name, [])
    events_str = if events == [], do: "(direct)", else: Enum.join(events, ", ")

    tree = render_tree(nodes, 0)

    [
      "### #{name} -- #{desc}\n",
      "Events: #{events_str}\n",
      "```",
      tree,
      "```\n",
      "---\n"
    ]
  end

  defp render_tree(nodes, depth) do
    nodes
    |> Enum.map(fn node -> render_node(node, depth) end)
    |> Enum.join("\n")
  end

  defp render_node({:segment, id, optionality}, depth) do
    indent = String.duplicate("  ", depth)
    "#{indent}#{format_segment(id, optionality, false)}"
  end

  defp render_node({:segment, id, optionality, :repeating}, depth) do
    indent = String.duplicate("  ", depth)
    "#{indent}#{format_segment(id, optionality, true)}"
  end

  defp render_node({:group, name, optionality, children}, depth) do
    indent = String.duplicate("  ", depth)
    group_label = format_group(name, optionality, false)
    inner = render_tree(children, depth + 1)
    "#{indent}#{group_label} {\n#{inner}\n#{indent}}"
  end

  defp render_node({:group, name, optionality, :repeating, children}, depth) do
    indent = String.duplicate("  ", depth)
    group_label = format_group(name, optionality, true)
    inner = render_tree(children, depth + 1)
    "#{indent}#{group_label} {\n#{inner}\n#{indent}}"
  end

  defp format_segment(id, :required, false), do: "#{id}"
  defp format_segment(id, :required, true), do: "#{id}*"
  defp format_segment(id, :optional, false), do: "[#{id}]"
  defp format_segment(id, :optional, true), do: "[#{id}*]"

  defp format_group(name, :required, false), do: "#{name}"
  defp format_group(name, :required, true), do: "#{name}*"
  defp format_group(name, :optional, false), do: "[#{name}]"
  defp format_group(name, :optional, true), do: "[#{name}]*"

  defp sharing_summary(event_map, _structures) do
    shared =
      event_map
      |> Enum.filter(fn {_struct, events} -> length(events) > 1 end)
      |> Enum.sort_by(fn {struct, _} -> struct end)

    rows =
      Enum.map(shared, fn {struct, events} ->
        "| #{struct} | #{Enum.join(events, ", ")} |"
      end)

    """

    ## Abstract Message Structure Sharing Summary

    Multiple trigger events share the same abstract message structure.

    | Structure | Trigger Events |
    |-----------|----------------|
    #{Enum.join(rows, "\n")}

    ---

    """
  end

  defp segment_names_table(structures) do
    # Collect all segment IDs used across all structures
    all_ids =
      structures
      |> Enum.flat_map(fn {_name, %{nodes: nodes}} -> collect_segment_ids(nodes) end)
      |> Enum.uniq()
      |> Enum.sort()

    rows =
      Enum.map(all_ids, fn id ->
        name =
          case HL7v2.Standard.segment(to_string(id)) do
            %{name: n} -> n
            nil -> to_string(id)
          end

        "| #{id} | #{name} |"
      end)

    """
    ## Segment Quick Reference

    | Code | Full Name |
    |------|-----------|
    #{Enum.join(rows, "\n")}

    ---

    ## Sources

    - HL7 v2.5.1 Standard
    - [Caristix HL7-Definition V2](https://hl7-definition.caristix.com/v2/HL7v2.5.1/TriggerEvents)
    - [HL7 Europe v2.5.1 Message Structures](https://www.hl7.eu/HL7v2x/v251/hl7v251msgstruct.htm)
    """
  end

  defp collect_segment_ids([]), do: []

  defp collect_segment_ids([{:segment, id, _opt} | rest]) do
    [id | collect_segment_ids(rest)]
  end

  defp collect_segment_ids([{:segment, id, _opt, :repeating} | rest]) do
    [id | collect_segment_ids(rest)]
  end

  defp collect_segment_ids([{:group, _name, _opt, children} | rest]) do
    collect_segment_ids(children) ++ collect_segment_ids(rest)
  end

  defp collect_segment_ids([{:group, _name, _opt, :repeating, children} | rest]) do
    collect_segment_ids(children) ++ collect_segment_ids(rest)
  end

  # ---------------------------------------------------------------------------
  # Segments
  # ---------------------------------------------------------------------------

  defp generate_segments(docs_dir) do
    segment_ids = HL7v2.Standard.typed_segment_ids()

    lines = [header_segments()] ++ Enum.flat_map(segment_ids, &render_segment/1)

    path = Path.join(docs_dir, "segments.md")
    File.write!(path, Enum.join(lines, "\n"))
    Mix.shell().info("Generated #{path} (#{length(segment_ids)} segments)")
  end

  defp header_segments do
    """
    # HL7 v2.5.1 Segment Definitions Reference

    Field-by-field definitions for all #{length(HL7v2.Standard.typed_segment_ids())} typed segments
    in the HL7 v2.5.1 standard as implemented by this library.

    **Generated from code metadata** -- do not edit by hand.
    Run `mix hl7v2.gen_docs` to regenerate.

    **Optionality codes:** R = Required, O = Optional, C = Conditional, B = Backward compatible

    **Repetition:** 1 = single, * = unbounded repeating

    ---
    """
  end

  defp render_segment(seg_id) do
    meta = HL7v2.Standard.segment(seg_id)
    mod = HL7v2.Standard.segment_module(seg_id)

    case mod do
      nil ->
        []

      _ ->
        Code.ensure_loaded!(mod)

        if function_exported?(mod, :fields, 0) do
          fields = mod.fields()

          [
            "## #{seg_id} -- #{meta.name}\n",
            "#{length(fields)} fields.\n",
            "| Seq | Name | Type | Opt | Rep |",
            "|-----|------|------|-----|-----|"
          ] ++
            Enum.map(fields, fn {seq, name, type, opt, reps} ->
              type_str = format_type(type)
              opt_str = format_opt(opt)
              rep_str = format_reps(reps)
              name_str = name |> to_string() |> humanize()
              "| #{seg_id}.#{seq} | #{name_str} | #{type_str} | #{opt_str} | #{rep_str} |"
            end) ++ ["\n---\n"]
        else
          []
        end
    end
  end

  defp format_type(:raw), do: "varies"

  defp format_type(mod) when is_atom(mod) do
    mod |> Module.split() |> List.last()
  end

  defp format_opt(:r), do: "R"
  defp format_opt(:o), do: "O"
  defp format_opt(:c), do: "C"
  defp format_opt(:b), do: "B"

  defp format_reps(1), do: "1"
  defp format_reps(:unbounded), do: "*"
  defp format_reps(n) when is_integer(n), do: "#{n}"

  defp humanize(str) do
    str
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  # ---------------------------------------------------------------------------
  # Data Types
  # ---------------------------------------------------------------------------

  defp generate_data_types(docs_dir) do
    type_codes = HL7v2.Standard.typed_type_codes()

    primitives =
      Enum.filter(type_codes, fn code ->
        HL7v2.Standard.type(code).category == :primitive
      end)

    composites =
      Enum.filter(type_codes, fn code ->
        HL7v2.Standard.type(code).category == :composite
      end)

    lines =
      [header_data_types()] ++
        ["\n## Primitive Data Types\n", "| Code | Name |", "|------|------|"] ++
        Enum.map(primitives, fn code ->
          meta = HL7v2.Standard.type(code)
          "| #{code} | #{meta.name} |"
        end) ++
        ["\n---\n", "\n## Composite Data Types\n"] ++
        Enum.flat_map(composites, &render_data_type/1)

    path = Path.join(docs_dir, "data-types.md")
    File.write!(path, Enum.join(lines, "\n"))

    Mix.shell().info(
      "Generated #{path} (#{length(type_codes)} types: #{length(primitives)} primitive, #{length(composites)} composite)"
    )
  end

  defp header_data_types do
    """
    # HL7 v2.5.1 Data Type Definitions

    Component-by-component reference for all #{HL7v2.Standard.type_count()} data types
    in the HL7 v2.5.1 standard as implemented by this library.

    **Generated from code metadata** -- do not edit by hand.
    Run `mix hl7v2.gen_docs` to regenerate.

    ---
    """
  end

  defp render_data_type(code) do
    meta = HL7v2.Standard.type(code)
    mod = Module.concat(HL7v2.Type, code)
    Code.ensure_loaded!(mod)

    struct_info = mod.__info__(:struct) || []

    if struct_info == [] do
      # Primitive-like composite (rare) -- just show the name
      ["### #{code} -- #{meta.name}\n", "(No component structure)\n", "---\n"]
    else
      components =
        struct_info
        |> Enum.with_index(1)
        |> Enum.map(fn {%{field: name}, idx} ->
          "| #{idx} | #{name |> to_string() |> humanize()} |"
        end)

      [
        "### #{code} -- #{meta.name}\n",
        "#{length(struct_info)} components.\n",
        "| # | Component |",
        "|---|-----------|"
      ] ++ components ++ ["\n---\n"]
    end
  end
end
