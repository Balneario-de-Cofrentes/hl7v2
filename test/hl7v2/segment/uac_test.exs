defmodule HL7v2.Segment.UACTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.UAC
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(UAC.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns UAC" do
      assert UAC.segment_id() == "UAC"
    end
  end

  describe "parse/1" do
    test "parses credential type code and credential" do
      raw = [
        ["KERB", "Kerberos", "HL70615"],
        ["Kerberos", "TKT", "Application", "Base64", "<base64data>"]
      ]

      result = UAC.parse(raw)

      assert %UAC{} = result

      assert %HL7v2.Type.CWE{
               identifier: "KERB",
               text: "Kerberos",
               name_of_coding_system: "HL70615"
             } = result.user_authentication_credential_type_code

      assert %HL7v2.Type.ED{
               source_application: %HL7v2.Type.HD{namespace_id: "Kerberos"},
               type_of_data: "TKT",
               data_subtype: "Application",
               encoding: "Base64",
               data: "<base64data>"
             } = result.user_authentication_credential
    end

    test "parses empty list -- all fields nil" do
      result = UAC.parse([])

      assert %UAC{} = result
      assert result.user_authentication_credential_type_code == nil
      assert result.user_authentication_credential == nil
    end
  end

  describe "encode/1 round-trip" do
    test "parse -> encode -> parse preserves required fields" do
      raw = [
        ["KERB", "Kerberos", "HL70615"],
        ["Kerberos", "TKT", "Application", "Base64", "<base64data>"]
      ]

      encoded = raw |> UAC.parse() |> UAC.encode()
      reparsed = UAC.parse(encoded)

      assert reparsed.user_authentication_credential_type_code.identifier == "KERB"
      assert reparsed.user_authentication_credential_type_code.text == "Kerberos"
      assert reparsed.user_authentication_credential_type_code.name_of_coding_system == "HL70615"

      assert reparsed.user_authentication_credential.source_application.namespace_id == "Kerberos"
      assert reparsed.user_authentication_credential.type_of_data == "TKT"
      assert reparsed.user_authentication_credential.data_subtype == "Application"
      assert reparsed.user_authentication_credential.encoding == "Base64"
      assert reparsed.user_authentication_credential.data == "<base64data>"
    end

    test "encodes all-nil struct to empty list" do
      assert UAC.encode(%UAC{}) == []
    end
  end

  describe "typed parsing integration" do
    test "wire line UAC|KERB^Kerberos^HL70615|... parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ACK|1|P|2.7\r" <>
          "UAC|KERB^Kerberos^HL70615|Kerberos^TKT^Application^Base64^<base64data>\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      uac = Enum.find(msg.segments, &is_struct(&1, UAC))

      assert %UAC{} = uac
      assert uac.user_authentication_credential_type_code.identifier == "KERB"
      assert uac.user_authentication_credential_type_code.text == "Kerberos"
      assert uac.user_authentication_credential.type_of_data == "TKT"
      assert uac.user_authentication_credential.data_subtype == "Application"
      assert uac.user_authentication_credential.encoding == "Base64"
      assert uac.user_authentication_credential.data == "<base64data>"
    end
  end

  describe "required field validation" do
    test "both fields are declared as required (:r)" do
      required =
        UAC.fields()
        |> Enum.filter(fn {_seq, _name, _type, opt, _reps} -> opt == :r end)
        |> Enum.map(fn {_seq, name, _type, _opt, _reps} -> name end)

      assert :user_authentication_credential_type_code in required
      assert :user_authentication_credential in required
      assert length(required) == 2
    end

    test "missing credential type code produces a validation error" do
      segment = %UAC{
        user_authentication_credential_type_code: nil,
        user_authentication_credential: %HL7v2.Type.ED{
          type_of_data: "TKT",
          data_subtype: "Application",
          encoding: "Base64",
          data: "<base64data>"
        }
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn err ->
               err.level == :error and
                 err.location == "UAC" and
                 err.field == :user_authentication_credential_type_code
             end)
    end

    test "missing credential produces a validation error" do
      segment = %UAC{
        user_authentication_credential_type_code: %HL7v2.Type.CWE{
          identifier: "KERB",
          text: "Kerberos",
          name_of_coding_system: "HL70615"
        },
        user_authentication_credential: nil
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn err ->
               err.level == :error and
                 err.location == "UAC" and
                 err.field == :user_authentication_credential
             end)
    end

    test "populated required fields produce no required-field errors" do
      segment = %UAC{
        user_authentication_credential_type_code: %HL7v2.Type.CWE{
          identifier: "KERB",
          text: "Kerberos",
          name_of_coding_system: "HL70615"
        },
        user_authentication_credential: %HL7v2.Type.ED{
          source_application: %HL7v2.Type.HD{namespace_id: "Kerberos"},
          type_of_data: "TKT",
          data_subtype: "Application",
          encoding: "Base64",
          data: "<base64data>"
        }
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, fn err ->
               err.level == :error and String.contains?(err.message, "required field")
             end)
    end
  end
end
