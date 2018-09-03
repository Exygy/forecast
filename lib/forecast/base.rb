module Forecast
  class Base
    attr_reader :attributes

    def self.connection
      Forecast.connection
    end

    def self.url_single_name
      self.name.demodulize.underscore
    end

    def self.url_plural_name
      self.url_single_name.pluralize
    end

    def self.all(query = {})
      uri = Addressable::URI.new
      uri.query_values = query

      url = "/#{url_plural_name}"
      url << "?#{uri.query}" if query.any?

      @all = connection.get(url).body[url_plural_name].map do |attributes|
        new(attributes)
      end
    end

    def self.get(id)
      url = "/#{url_plural_name}/#{id}"
      new(connection.get(url).body[url_single_name])
    end

    def initialize(attributes = {})
      @attributes = HashWithIndifferentAccess.new(attributes)
    end

    private

    def method_missing(name)
      key = name.to_s
      if @attributes.key?(key.to_s)
        @attributes[key]
      else
        super
      end
    end
  end
end
