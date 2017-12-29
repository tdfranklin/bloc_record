require 'sqlite3'
require 'pg'

module Connection
    def connection
        @connection ||= SQLite3::Database.new(BlocRecord.database_filename) if BlocRecord.database_type == :sqlite3
        @connection ||= PostgreSQL::Database.new(BlocRecord.database_filename) if BlocRecord.database_type == :pg
    end
end