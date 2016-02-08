class Slider

  include Mongoid::Document

  field :size, type: Integer
  field :unit, type: String
  field :value, type: Integer


  def __bson_dump__(io = "", key = nil)
    as_document.__bson_dump__(io, key)
  end

end




