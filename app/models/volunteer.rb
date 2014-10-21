class Volunteer

  attr_accessor :position_title, :description

  def initialize (attributes = {})
    @position_title = attributes[:position_title]
    @description = attributes[:description]
  end
end