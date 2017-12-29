module BlocRecord
    def self.connect_to(filename, target)
        @database_filename = filename
        @database_type = target
    end

    def self.database_filename
        @database_filename
    end

    def self.database_type
        @database_type
    end
end