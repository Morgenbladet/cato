json.array!(@institutions) do |institution|
  json.extract! institution, :id, :name, :abbreviation, :priority
  json.url institution_url(institution, format: :json)
end
