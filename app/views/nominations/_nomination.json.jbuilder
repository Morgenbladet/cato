json.extract! nomination, :id, :institution_id, :name
json.institution do
  json.abbreviation nomination.institution.abbreviation
  json.name nomination.institution.name
end
json.reasons nomination.reasons do |reason|
  json.reason reason.reason
  json.reason_html simple_format(reason.reason)
  json.nominator reason.nominator
end
