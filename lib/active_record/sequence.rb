require "active_record"
require "active_record/sequence/version"
require "active_record/sequence/error"
require "active_support/core_ext/module/delegation"

module ActiveRecord
  # Usage
  #   sequence = Sequence.new('numbers')
  #   sequence.next #=> 1
  #   sequence.peek #=> 1
  #   sequence.next #=> 2
  #
  class Sequence
    autoload :SequenceSQLBuilder, "active_record/sequence/sequence_sql_builder"

    class << self
      CREATE_ERRORS = {
        "PG::DuplicateTable" => ActiveRecord::Sequence::AlreadyExist
      }.freeze
      # Create sequence
      # @param name [String]
      # @param options [{}]
      # @option options [Integer] :start (1)
      # @option options [Integer] :increment (1) specifies which value is added to
      #   the current sequence value to create a new value. A positive value will
      #   make an ascending sequence, a negative one a descending sequence.
      # @option options [Integer] :min determines the minimum value a sequence can generate.
      #   The defaults are 1 and -2^63-1 for ascending and descending sequences, respectively.
      # @option options [Integer] :max determines the maximum value for the sequence.
      #   The defaults are 2^63-1 and -1 for ascending and descending sequences, respectively.
      # @option options [Boolean] :cycle (false) allows the sequence to wrap around when the
      #   max value or min value has been reached by an ascending or descending sequence respectively.
      #   If the limit is reached, the next number generated will be the min value or max value, respectively.
      # @return [Sequence]
      # @see https://www.postgresql.org/docs/8.1/static/sql-createsequence.html
      def create(name, options = {})
        create_sql = SequenceSQLBuilder.new(name, options).to_sql
        handle_postgres_errors(CREATE_ERRORS) do
          with_connection do |connection|
            connection.execute(create_sql)
          end
        end
        new(name)
      end

      DROP_ERRORS = {
        "PG::UndefinedTable" => NotExist
      }.freeze

      # @param name [String]
      # @return [void]
      def drop(name)
        drop_sql = format("DROP SEQUENCE %s", name)
        handle_postgres_errors(DROP_ERRORS) do
          with_connection do |connection|
            connection.execute(drop_sql)
          end
        end
      end

      # @api private
      def with_connection
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          yield(connection)
        end
      end

      # @param mappings [{}] from PG errors to library errors
      # @api private
      def handle_postgres_errors(mappings)
        yield
      rescue ActiveRecord::StatementInvalid => error
        library_error = mappings.fetch(error.cause.class.name) { raise }
        raise library_error
      end
    end

    attr_reader :name

    # @param name [String]
    def initialize(name)
      @name = name
    end

    NEXT_ERRORS = {
      "PG::ObjectNotInPrerequisiteState" => StopIteration,
      "PG::SequenceGeneratorLimitExceeded" => StopIteration,
      "PG::UndefinedTable" => ActiveRecord::Sequence::NotExist
    }.freeze

    # @return [Integer]
    def next
      next_sql = "SELECT nextval(%s)".freeze
      handle_postgres_errors(NEXT_ERRORS) do
        execute(next_sql, name)
      end
    end

    PEEK_ERRORS = {
      "PG::ObjectNotInPrerequisiteState" => ActiveRecord::Sequence::CurrentValueUndefined,
      "PG::UndefinedTable" => ActiveRecord::Sequence::NotExist
    }.freeze

    # @return [Integer]
    def peek
      current_sql = "SELECT currval(%s)".freeze
      handle_postgres_errors(PEEK_ERRORS) do
        execute(current_sql, name)
      end
    end

    private

    delegate :handle_postgres_errors, to: :class
    delegate :with_connection, to: :class

    def execute(sql, *args)
      with_connection do |connection|
        connection.select_value(prepare_query(sql, *args)).to_i
      end
    end

    def prepare_query(sql, *args)
      quoted_args = args.map do |arg|
        with_connection do |connection|
          connection.quote(arg)
        end
      end
      format(sql, *quoted_args)
    end
  end
end
