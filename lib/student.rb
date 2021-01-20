class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id, @name, @grade = id, name, grade
  end

  def self.create_table
    sql = <<-SQL
    create table if not exists students (
      id INTEGER PRIMARY KEY,
      name text,
      grade integer
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    drop table if exists students
    SQL

    DB[:conn].execute(sql)
  end
  
  def save
    if @id
      self.update
    else
    sql = <<-SQL
    INSERT INTO students (name, grade) 
    Values (?,?)

    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    
  end
  

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = "select * from students where name = ?"
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "update students set name = ?, grade = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
