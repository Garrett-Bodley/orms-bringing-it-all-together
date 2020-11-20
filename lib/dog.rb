class Dog

  attr_accessor :name, :breed, :id

  def initialize(attr_hash={})
    attr_hash.each {|key, value| self.send("#{key.to_s}=", value) if self.respond_to?("#{key.to_s}=")}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (id, name, breed) VALUES (?, ?, ?);"
      DB[:conn].execute(sql, self.id, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create(attr_hash)
    self.new(attr_hash).tap {|dog| dog.save}
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(attr_hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])
    dog.empty? ? self.create(attr_hash) : self.new_from_db(dog[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end
end