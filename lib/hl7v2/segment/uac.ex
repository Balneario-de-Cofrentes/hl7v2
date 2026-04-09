defmodule HL7v2.Segment.UAC do
  @moduledoc """
  User Authentication Credential (UAC) segment — HL7v2 v2.7+.

  Introduced in HL7 v2.7 for inter-system user authentication. Carries
  credentials (e.g., Kerberos ticket, SAML assertion, user ID + secret)
  when one system acts on behalf of a user in another system.

  2 fields per HL7 v2.7 specification.
  """

  use HL7v2.Segment,
    id: "UAC",
    fields: [
      {1, :user_authentication_credential_type_code, HL7v2.Type.CWE, :r, 1},
      {2, :user_authentication_credential, HL7v2.Type.ED, :r, 1}
    ]
end
