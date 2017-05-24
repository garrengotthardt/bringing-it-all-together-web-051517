require "pry"

class Dog
  attr_accessor :name, :breed, :id

  def initialize (name: name, breed: breed, id: id=nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end


  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name)[0]
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog
  end

  def self.find_or_create_by(name: name, breed: breed)
    #binding.pry
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;", name, breed)[0]
    #binding.pry
    if !!dog_row
      dog = self.new_from_db(dog_row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end






end
