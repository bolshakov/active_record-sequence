module ActiveRecord
  class Sequence # rubocop:disable Style/Documentation
    # Builds SQL statement for creating sequence
    # @api private
    class SequenceSQLBuilder
      attr_reader :options
      attr_reader :parts

      def initialize(name, options = {})
        @options = options
        @parts = [format('CREATE SEQUENCE %s', name)]
      end

      def to_sql
        configure_increment
        configure_min_value
        configure_max_value
        configure_start_value
        configure_cycle
        parts.join(' ')
      end

      private

      def configure_increment
        parts << format('INCREMENT BY %s', options[:increment]) if options[:increment]
      end

      def configure_min_value
        parts << format('MINVALUE %s', options[:min]) if options[:min]
      end

      def configure_max_value
        parts << format('MAXVALUE %s', options[:max]) if options[:max]
      end

      def configure_start_value
        parts << format('START %s', options[:start]) if options[:start]
      end

      def configure_cycle
        parts << (options.fetch(:cycle, false) ? 'CYCLE' : 'NO CYCLE')
      end
    end

    private_constant(:SequenceSQLBuilder)
  end
end
