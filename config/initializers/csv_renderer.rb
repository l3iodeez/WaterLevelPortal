# frozen_string_literal: true

require 'csv' # adds a .to_csv method to Array instances

class Array
  alias old_to_csv to_csv # keep reference to original to_csv method

  def to_csv(options = {})
    # override only if first element actually has as_csv method
    return old_to_csv(options) unless first.respond_to? :as_csv
    # use keys from first row as header columns
    out = first.as_csv.keys.to_csv(options)
    each { |r| out << r.as_csv.values.to_csv(options) + '\n' }
    out
  end
end

ActionController::Renderers.add :csv do |csv, _options|
  csv = csv.respond_to?(:to_csv) ? csv.to_csv : csv
  self.content_type ||= Mime::CSV
  self.response_body = csv
end
