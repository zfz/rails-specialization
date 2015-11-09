json.array!(@todo_lists) do |todo_list|
  json.extract! todo_list, :id, :list_name, :list_due_date
  json.url todo_list_url(todo_list, format: :json)
end
