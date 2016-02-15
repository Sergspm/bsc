class BinConfiguration

  include Mongoid::Document
  store_in collection: "bin_configurations"
  embeds_many :sliders

  validates :conf_type, inclusion: { in: %w(constant random bins), message: "Unknown type of configuration: %{value}" }
  validates :random_from_unit, inclusion: { in: %w(b kb mb gb), message: "Unknown unit of random from unit: %{value}" }
  validates :random_to_unit, inclusion: { in: %w(b kb mb gb), message: "Unknown unit of random to unit: %{value}" }

  field :conf_type, type: String
  field :constant_size, type: String
  field :random_from_unit, type: String
  field :random_to_unit, type: String
  field :random_from_value, type: Integer
  field :random_to_value, type: Integer
  field :sliders, type: Array

end