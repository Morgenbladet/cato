# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

schools = [
  [ "Universitetet i Oslo", "UiO", 5],
  [ "Nord universitet", "NORD", 5],
  [ "Norges miljø- og biovitenskapelige universitet", "NMBU", 5],
  [ "Norges teknisk-naturvitenskapelige universitet", "NTNU", 5],
  [ "Universitetet i Agder", "UiA", 5],
  [ "Universitetet i Bergen", "UiB", 5],
  [ "Universitetet i Stavanger", "UiS", 5],
  [ "Universitetet i Tromsø", "UiT", 5],

  [ "Arkitektur- og designhøgskolen", "AHO", 4],
  [ "Handelshøyskolen BI", "BI", 4],
  [ "Høgskolen i Molde", "HiM", 4],
  [ "Norges Handelshøyskole", "NHH", 4],
  [ "Norges idrettshøgskole", "NIH", 4],
  [ "Norges musikkhøgskole", "NMH", 4],
  [ "Det teologiske Menighetsfakultet", "MF", 4],
  [ "VID vitenskapelige høgskole", "VID", 4],

  [ "Høgskolen i Bergen", "HiB", 2],
  [ "Høgskolen i Hedmark", "HiH", 2],
  [ "Høgskolen i Lillehammer", "HiL", 2],
  [ "Høgskolen i Oslo og Akershus", "HiOA", 2],
  [ "Høgskulen i Sogn og Fjordane", "HiSF", 2],
  [ "Høgskolen i Stord/Haugesund", "HSH", 2],
  [ "Høgskolen i Sørøst-Norge", "HSN", 2],
  [ "Høgskulen i Volda", "HiVolda", 2],
  [ "Høgskolen i Østfold", "HiØ", 2],
  [ "Kunsthøgskolen i Bergen", "KHiB", 2],
  [ "Kunsthøgskolen i Oslo", "KHiO", 2],
  [ "Samisk høgskole (Sámi allaskuvla)", "SAMI", 2],

  [ "Forsvarets etterretningshøgskole", "FEH", 1],
  [ "Krigsskolen", "KS", 1],
  [ "Sjøkrigsskolen", "SKS", 1],
  [ "Luftkrigsskolen", "LKS", 1],
  [ "Forsvarets ingeniørhøgskole", "FIH", 1],
  [ "Forsvarets høgskole", "FHS", 1],
  [ "Politihøgskolen", "PHS", 1],

  [ "Ansgar Teologiske Høgskole", "ATH", 0],
  [ "Campus Kristiania Høyskolen", "CKH", 0],
  [ "Dronning Mauds Minne Høgskole", "DMMH", 0],
  [ "Lovisenberg diakonale høgskole", "LDH", 0],
  [ "Norges informasjonsteknologiske høgskole", "NITH", 0],
  [ "NLA Høgskolen", "NLA", 0],
  [ "Westerdals School of Communication", "WSC", 0]]

schools.each do |s|
  Institution.create! name: s[0], abbreviation: s[1], priority: s[2]
end
