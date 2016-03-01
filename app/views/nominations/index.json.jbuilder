json.array!(@nominations) do |nomination|
  json.extract! nomination, :id, :institution_id, :name, :reason, :nominator, :nominator_email, :verified, :votes
  json.url nomination_url(nomination, format: :json)
end
