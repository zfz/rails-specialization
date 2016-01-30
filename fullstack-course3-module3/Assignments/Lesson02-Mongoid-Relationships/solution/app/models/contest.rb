class Contest
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  field :name, type: String
  field :date, type: Date

  embeds_many :entrants
  belongs_to :venue
  has_and_belongs_to_many :judges
end
