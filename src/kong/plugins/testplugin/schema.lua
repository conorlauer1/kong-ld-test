local typedefs = require "kong.db.schema.typedefs"

return {
  name = "testplugin",
  fields = {
    {
      consumer = typedefs.no_consumer
    },
    {
      config = {
        type = "record",
        fields = {
        },
      },
    },
  }
}
