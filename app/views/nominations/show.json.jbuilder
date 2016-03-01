json.extract! @nomination, :id, :institution_id, :name, :reason, :nominator
json.institution do 
  json.abbreviation @nomination.institution.abbreviation
  json.name @nomination.institution.name
end
