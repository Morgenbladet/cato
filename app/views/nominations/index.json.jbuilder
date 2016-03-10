json.array!(@nominations) do |nomination|
  json.extract! nomination, :id, :institution_id, :name, :reason, :nominator
  json.reason_html simple_format(nomination.reason)
  json.institution do 
    json.abbreviation nomination.institution.abbreviation
    json.name nomination.institution.name
  end
  json.url nomination_url(nomination, format: :json)
end
