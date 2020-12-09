class Dog
    attr_accessor :name, :breed, :id
    def initialize (name:,breed:,id: id=nil)
        @name, @breed, @id = name, breed, id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs(name, breed) VALUES (?,?)
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:,breed:)
        new_dog = self.new(name: name,breed: breed)
        new_dog.save
        new_dog
    end
    
    def self.new_from_db(row)
        # new_dog = Dogs.new
        # new_dog.id = row[0]
        # new_dog.name = row[1]
        # new_dog.breed = row[2]
        # new_dog
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
          end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT *
         FROM dogs
          WHERE name = ? 
          AND breed = ? 
          LIMIT 1
        SQL
        new_dog = DB[:conn].execute(sql,name,breed)
        if !new_dog.empty?
            dog_data = new_dog[0]
            new_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
  
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
# def self.find_or_create_by(name:, breed:)
#     sql = <<-SQL
#           SELECT *
#           FROM dogs
#           WHERE name = ?
#           AND breed = ?
#           LIMIT 1
#         SQL

#     dog = DB[:conn].execute(sql,name,breed)

#     if !dog.empty?
#       dog_data = dog[0]
#       dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
#     else
#       dog = self.create(name: name, breed: breed)
#     end
#     dog
#   end