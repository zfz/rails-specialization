class Entrant
  include Mongoid::Document
  field :name, type: String
  field :group, type: String
  field :secs, type: Float

  embedded_in :contest
  belongs_to :racer, validate: true

  #cache the racer's name before creating
  before_create do |doc|
    r=doc.racer
    if r
      doc.name="#{r.last_name}, #{r.first_name}"
    end
  end
end
