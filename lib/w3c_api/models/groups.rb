# frozen_string_literal: true

module W3cApi
  module Models
    # Collection wrapper for groups
    class Groups
      include Enumerable

      attr_accessor :groups

      def initialize(groups = [])
        @groups = groups
      end

      def each(&)
        @groups.each(&)
      end

      def first
        @groups.first
      end

      def size
        @groups.size
      end

      def empty?
        @groups.empty?
      end
    end
  end
end
