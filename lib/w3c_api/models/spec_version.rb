# frozen_string_literal: true

require_relative 'base'
require_relative 'link'

# Example spec version response format:
# {
#   "date": "2023-09-21"
#   "status": "REC"
#   "rec_track": true
#   "editor-draft": "https://w3c.github.io/example-draft/"
#   "uri": "https://www.w3.org/TR/2023/REC-example-20230921/"
#   "title": "Example Specification"
#   "shortlink": "https://www.w3.org/TR/example/"
#   "process-rules": "2021"
#   "_links": {
#     "self": {
#       "href": "https://api.w3.org/specifications/example/versions/20230921"
#     },
#     "specification": {
#       "href": "https://api.w3.org/specifications/example"
#     }
#   }
# }

module W3cApi
    module Models
      class SpecVersionLinks < Lutaml::Model::Serializable
        attribute :self, Link
        attribute :specification, Link
      end

      class SpecVersion < Base
        attribute :status, :string
        attribute :rec_track, :boolean
        attribute :editor_draft, :string
        attribute :uri, :string, pattern: %r{https://www\.w3\.org/.*}
        attribute :date, :date_time # Date-time format
        attribute :last_call_feedback_due, :date_time # Date-time format
        attribute :pr_reviews_date, :date_time # Date-time format
        attribute :implementation_feedback_due, :date_time # Date-time format
        attribute :per_reviews_due, :date_time # Date-time format
        attribute :informative, :boolean
        attribute :title, :string
        attribute :href, :string
        attribute :shortlink, :string, pattern: %r{https://www\.w3\.org/.*}
        attribute :translation, :string
        attribute :errata, :string
        attribute :process_rules, :string
        attribute :_links, SpecVersionLinks

        # Return the specification this version belongs to
        def specification(client = nil)
          return nil unless client && _links&.specification

          spec_href = _links.specification.href
          spec_shortname = spec_href.split('/').last

          client.specification(spec_shortname)
        end

        # Check if this spec version is a Recommendation
        def recommendation?
          status == 'REC'
        end

        # Check if this spec version is a Working Draft
        def working_draft?
          status == 'WD'
        end

        # Check if this spec version is a Candidate Recommendation
        def candidate_recommendation?
          status == 'CR'
        end

        def self.from_response(response)
          transformed_response = transform_keys(response)

          spec_version = new
          transformed_response.each do |key, value|
            case key
            when :_links
              links = value.each_with_object({}) do |(link_name, link_data), acc|
                acc[link_name] = Link.new(href: link_data[:href], title: link_data[:title])
              end
              spec_version._links = SpecVersionLinks.new(links)
            else
              spec_version.send("#{key}=", value) if spec_version.respond_to?("#{key}=")
            end
          end
          spec_version
        end
      end
    end
end
