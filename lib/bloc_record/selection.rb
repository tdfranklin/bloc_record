require 'sqlite3'

module Selection
    def find(*ids)
        ids.each do |id|
            unless id.is_a? Numeric && id > 0
                raise ArgumentError.new('ID must be a number and greater than 0')
            end
        end

        if ids.length == 1
            find_one(ids.first)
        else
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                WHERE id IN (#{ids.join(",")});
            SQL

            rows_to_array(rows)
        end
    end

    def find_one(id)
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            WHERE id = #{id};
        SQL

        init_object_from_row(row)
    end

    def find_by(attribute, value)
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
        SQL

        init_object_from_row(row)
    end

    def take(num=1)
        unless num.is_a? Numeric && num > 0
            raise ArgumentError.new('Must be a number and greater than 0')
        end

        if num > 1
            rows = connection.execute <<-SQL
                SELECT #{columns.join ","} FROM #{table}
                ORDER BY random()
                LIMIT #{num};
            SQL

            rows_to_array(rows)
        else
            take_one
        end
    end

    def take_one
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY random()
            LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def first
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id ASC LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def last
        row = connection.get_first_row <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id DESC LIMIT 1;
        SQL

        init_object_from_row(row)
    end

    def all
        rows = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table};
        SQL

        rows_to_array(rows)
    end

    def some(offset, limit)
        rows = connection.execute <<-SQL
            SELECT #{columns.join ","} FROM #{table}
            ORDER BY id ASC LIMIT #{limit}, #{offset};
        SQL

        rows_to_array(rows)
    end

    def method_missing(m, *args, &block)
        first_part = m[/\A(find_by_)/]
        second_part = m[/find_by_(\w+)/,1]
        if first_part = "find_by_"
            find_by(second_part, args)
        else
            return "No #{m} method found"
        end
    end

    def find_each(options = {}, &block)
        if options.empty?
            records = all
        else
            start = options.values.first
            size = options.values.last
            records = some(start, size)
        end
        records.each do |record|
            yield(record)
        end
    end

    def find_in_batches(options = {}, &block)
        start = options.values.first
        size = options.values.last
        records = some(start, size)
        yield(records, start)
    end

    private
    def init_object_from_row(row)
        if row
            data = Hash[columns.zip(row)]
            new(data)
        end
    end

    def rows_to_array(rows)
        rows.map { |row| new(Hash[columns.zip(row)]) }
    end
end