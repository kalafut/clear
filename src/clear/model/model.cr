require "../sql"
require "./**"

module Clear::Model
  include Clear::Model::HasFields
  include Clear::Model::HasHooks
  include Clear::Model::HasTimestamps
  include Clear::Model::HasSaving
  include Clear::Model::HasValidation
  include Clear::Model::HasRelations

  getter? persisted : Bool

  # We use here included for errors purpose.
  # The overload are shown in this case, but not in the case the constructors
  # are directly defined without the included block.
  macro included
    def initialize
      @persisted = false
    end

    def initialize(h : Hash(String, ::Clear::SQL::Any), @persisted = false, fetch_columns = false )
      @attributes.merge!(h) if fetch_columns
      set(h)
    end

    def initialize(t : NamedTuple, @persisted = false)
      set(t)
    end
  end

  # For some reasons (the class "Collection" inheriting from Generic prevent working extension...
  # So the fields will be added manually
  macro included
    class_property table : Clear::SQL::Symbolic = self.name.downcase.pluralize

    class Collection < Clear::Model::CollectionBase({{@type}}); end
    extend Clear::Model::HasHooks::ClassMethods

    # extend Clear::Model::ClassMethods

    def self.query
      Collection.new.from(table)
    end

    def self.find(x)
      pk = pkey
      query.where { raw(pk) == x }.first
    end

    # Default primary query is "id"
    def self.pkey : String
      "id"
    end

    def self.fields
      @@fields
    end

    macro finished
      __generate_fields
    end
  end
end
