class TodoItem < ActiveRecord::Base
  def self.number_of_completed_todos
    TodoItem.where(completed: true).count
  end
end
