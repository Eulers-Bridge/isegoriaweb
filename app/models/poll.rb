class Poll
  include ActiveModel::Model

  attr_accessor :question, :date, :options, :picture
  attr_reader :id, :created, :modified

  validates :question, :presence => { :message => ApplicationHelper.validation_error(:question, :presence, nil) }
  validates :options, :presence => { :message => ApplicationHelper.validation_error(:options, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @question = attributes[:question]
    @date = attributes[:date]
  end

  def self.all
      [Poll.new(id: 1, question: "Who will win the FIFA World Cup?", date:"2014/05/31"), 
      Poll.new(id: 2, question: "Who will win Wimbledon?", date:"2014/06/01"),
      Poll.new(id: 3, question: "What was first, the hen or the egg?", date:"2014/06/02")]
  end

end