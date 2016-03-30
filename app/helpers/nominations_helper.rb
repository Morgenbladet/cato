module NominationsHelper
  def personalia(nomination)
    [
      case(nomination.gender)
      when "Male" then "♂"
      when "Female" then "♀"
      else nil
      end,
      nomination.age ? "#{nomination.age} år" : nil,
      nomination.branch.blank? ? nil : nomination.branch
    ].compact.join(", ")
  end
end
