require 'rrepo/adapters/base'

module RRepo
  module Adapters
    # A mongodb adapter
    class Mongo < Base
      include ::Mongo
      def initialize(options)
        db_name = options.delete(:db)
        @client = MongoClient.new(options.delete(:host), options)
        @db = @client[db_name]
      end

      def create(collection, model)
        @db[collection.to_s].insert(model.to_hash)
      end

      def update(collection, model)
        hash = model.to_hash
        @db[collection.to_s].update(id_query(model._id), hash)
      end

      def delete(collection, model)
        @db[collection.to_s].remove(id_query(model._id))
      end

      def all(collection)
        @db[collection.to_s].find
      end

      def find(collection, id)
        @db[collection].find(id_query(id))
      end

      def clear(collection)
        @db[collection].drop
      end

      def query(collection, &block)
        Query.new(@db[collection], &block)
      end

      # A Mongo Query object
      class Query
        def initialize(collection, &block)
          @collection = collection
          @query = {}
          instance_eval(&block) if block_given?
        end

        def where(condition)
          @query.merge(condition)
        end

        def run
          @collection.find(@query)
        end

        def to_hash
          @query
        end
      end

      protected

      def id_query(id)
        { _id: id }
      end
    end
  end
end
