defmodule GlobsFramework.Json.GlobTypeSetDeserializerTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Json.{Mapping, GlobTypeSetDeserializer, GlobTypeSerializer}
  alias GlobsFramework.Metamodel.{GlobType, GlobTypeResolver, FieldsBuilder, GlobTypeBuilder}
  alias GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation

  test "should deserialize a simple glob type set" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)

    serialized_glob_type_set =
      [glob_type]
      |> GlobTypeSerializer.serialize()

    [deserialized | _] = GlobTypeSetDeserializer.deserialize(serialized_glob_type_set, [])
    assert GlobType.get_name(deserialized) == "user"
    assert GlobType.get_field(deserialized, "name") == field
  end

  test "should deserialize a complexe glob type set" do
    serialized =
      "[{\"kind\":\"result\",\"fields\":[{\"name\":\"unknownProducts\",\"type\":\"globArray\",\"kind\":\"eanSkuType\"},{\"name\":\"four\",\"type\":\"glob\",\"kind\":\"FLUX_FOUR\"},{\"name\":\"errors\",\"type\":\"stringArray\"}]},{\"kind\":\"requiredAnnotationType\"},{\"kind\":\"FLUX_FOUR\",\"fields\":[{\"name\":\"LIGNE\",\"type\":\"globArray\",\"kind\":\"LIGNE\"}]},{\"kind\":\"_XmlAsCData\"},{\"kind\":\"fieldNameAnnotation\",\"fields\":[{\"name\":\"name\",\"type\":\"string\"}]},{\"kind\":\"eanSkuType\",\"fields\":[{\"name\":\"EAN\",\"type\":\"string\"},{\"name\":\"SKU\",\"type\":\"string\"}]},{\"kind\":\"maxSizeType\",\"fields\":[{\"name\":\"VALUE\",\"type\":\"int\"},{\"name\":\"ALLOW_TRUNCATE\",\"type\":\"boolean\"},{\"name\":\"CHARSET\",\"type\":\"string\"}]},{\"kind\":\"LIGNE\",\"fields\":[{\"name\":\"NUM_BL\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"DATE_PREVUE\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"LIBELLE_FOURN\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"maxSizeType\",\"VALUE\":50,\"ALLOW_TRUNCATE\":true,\"CHARSET\":\"UTF-8\"},{\"_kind\":\"requiredAnnotationType\"},{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"_XmlAsCData\"}]},{\"name\":\"CODE_ART\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"CODE_ART_FOURN\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"EAN\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"QTE_ATTENDUE\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false},{\"_kind\":\"requiredAnnotationType\"}]},{\"name\":\"NUM_COLIS\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":false}]},{\"name\":\"NUM_COMMANDE\",\"type\":\"string\",\"annotations\":[{\"_kind\":\"_XmlAsNode\",\"MANDATORY\":true},{\"_kind\":\"maxSizeType\",\"VALUE\":50,\"ALLOW_TRUNCATE\":false,\"CHARSET\":\"UTF-8\"}]}]},{\"kind\":\"_XmlAsNode\",\"fields\":[{\"name\":\"NAME\",\"type\":\"string\"},{\"name\":\"MANDATORY\",\"type\":\"boolean\"}]}]"

    deserialized_set = GlobTypeSetDeserializer.deserialize(serialized, [])
    resolver = GlobTypeResolver.from(deserialized_set)
    assert GlobType.get_name(GlobTypeResolver.get(resolver, "result")) == "result"
    assert GlobType.get_name(GlobTypeResolver.get(resolver, "FLUX_FOUR")) == "FLUX_FOUR"
  end
end
