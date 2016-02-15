class Slider

  include Mongoid::Document

  field :size, type: Integer
  field :unit, type: String
  field :value, type: Integer

  embedded_in :bin_configuration

end