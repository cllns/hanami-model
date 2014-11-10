require 'lotus/model/adapter_registry'

module Lotus
  module Model
    # Configuration for the framework, models and adapters.
    #
    # Lotus::Model has its own global configuration that can be manipulated
    # via `Lotus::Model.configure`.
    #
    # @since x.x.x
    class Configuration

      extend Forwardable
      delegate adapters: :adapter_registry

      # The persistence mapper
      #
      # @return [Lotus::Model::Mapper]
      #
      # @since x.x.x
      attr_reader :mapper

      # A registry of adapter templates
      #
      # @return [Lotus::Model::AdapterRegistry]
      #
      # @since x.x.x
      attr_reader :adapter_registry

      # Initialize a configuration instance
      #
      # @return [Lotus::Model::Configuration] a new configuration's
      #   instance
      #
      # @since x.x.x
      def initialize
        reset!
      end

      # Reset all the values to the defaults
      #
      # @return void
      #
      # @since x.x.x
      def reset!
        @adapter_registry ||= Lotus::Model::AdapterRegistry.new
        @adapter_registry.reset!
        @mapper = nil
      end

      alias_method :unload!, :reset!

      # Load the configuration for the current framework
      #
      # @return void
      #
      # @since x.x.x
      def load!
        adapter_registry.build(mapper)
        mapper.adapters = adapters
        mapper.load!
      end

      # Register adapter
      #
      # If `default` params is set to `true`, the adapter will be used as default one
      #
      # @param name    [Symbol] Unique adapter name
      # @param type    [Symbol] Derive adapter class name
      # @param uri     [String] The adapter uri
      # @param default [TrueClass, FalseClass] Decide if adapter is used by default
      #
      # @return void
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Config::Adapter
      #
      # @example Register SQL Adapter as default adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter name: :postgresql, type: :sql, uri: 'postgres://localhost/database', default: true
      #   end
      #
      #   Lotus::Model.adapters.default
      #   Lotus::Model.adapters.fetch(:postgresql)
      #
      # @example Register an adapter
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     adapter name: :sqlite3, type: :sql, uri: 'sqlite3://localhost/database'
      #   end
      #
      #   Lotus::Model.adapters.fetch(:sqlite3)
      #
      # @since x.x.x
      def adapter(**options)
        set_default_params(options)
        check_params(options)
        adapter_registry.register(options)
      end

      # Set global persistence mapper
      #
      # @return void
      #
      # @see Lotus::Model.configure
      # @see Lotus::Model::Mapper
      #
      # @example Set global persistence mapper
      #   require 'lotus/model'
      #
      #   Lotus::Model.configure do
      #     mapping do
      #       collection :users do
      #         entity User
      #
      #         attribute :id,   Integer
      #         attribute :name, String
      #       end
      #     end
      #   end
      #
      # @since x.x.x
      def mapping(&blk)
        if block_given?
          @mapper = Lotus::Model::Mapper.new(&blk)
        else
          raise Lotus::Model::InvalidMappingError
        end
      end

      private

      def set_default_params(options)
        options[:uri] ||= nil
        options[:default] ||= false
      end

      def check_params(options)
        [:name, :type].each do |keyword|
          raise ArgumentError.new("missing keyword: #{keyword}") if !options.keys.include?(keyword)
        end
      end
    end
  end
end
