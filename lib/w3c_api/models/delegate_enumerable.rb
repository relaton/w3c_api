# frozen_string_literal: true

module W3cApi
  module Models
    # Module for delegating Enumerable methods to a collection attribute
    module DelegateEnumerable
      # Define enumerable methods delegated to the specified collection attribute
      # @param collection_attr [Symbol] The name of the collection attribute
      def delegate_enumerable(collection_attr)
        include Enumerable

        define_method(:each) do |&block|
          send(collection_attr).each(&block)
        end

        define_method(:map) do |&block|
          send(collection_attr).map(&block)
        end

        define_method(:select) do |&block|
          send(collection_attr).select(&block)
        end

        define_method(:[]) do |index|
          send(collection_attr)[index]
        end

        define_method(:first) do
          send(collection_attr).first
        end

        define_method(:last) do
          send(collection_attr).last
        end

        define_method(:empty?) do
          send(collection_attr).empty?
        end

        define_method(:size) do
          send(collection_attr).size
        end

        define_method(:length) do
          send(collection_attr).length
        end

        define_method(:to_a) do
          send(collection_attr)
        end
      end
    end
  end
end
