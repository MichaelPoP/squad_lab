require 'pry'
require 'sinatra'
# require 'sinatra/reloader'
require 'better_errors'
require 'pg'

  configure :development do
     use BetterErrors::Middleware
     BetterErrors.application_root = __dir__
  end
#-------- CONFIGURATION VARIABLE SETTING --------

set :conn, PG.connect(dbname: 'dblab')

before do
  @conn = settings.conn
end

#------------------------------------------------
#   SQUAD GET ROUTES ----------------------------
#--------------- ROOT ROUTE ---------------------
  get '/' do
    redirect '/squads'
  end

#---------------- INDEX -------------------------
  get '/squads' do
    squads = []
    @conn.exec("SELECT * FROM squads ORDER BY id ASC") do |result|
      result.each do |squad|
        squads << squad
      end
    end
    @squads = squads
    erb :index
  end

#----------------- NEW SQUAD --------------------
  get '/squads/new' do
    erb :newsquad
  end

#----------------- SHOW SQUAD -------------------
get "/squads/:squad_id" do
 
  
  id = params[:squad_id].to_i
 
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
  students = []
  @conn.exec("SELECT * FROM students WHERE squad_id=$1", [id]) do |result|
    
    result.each do |student|
      students << student
    end
  end
    @students = students
    @squad = squad[0]
    erb :showsquad
end

#----------------- EDIT SQUAD -------------------
get '/squads/:squad_id/edit' do
  id = params[:squad_id].to_i
  
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
     
    @squad = squad[0]
    erb :editsquad
end
#------------------------------------------------
#------------------------------------------------
#------------------------------------------------




#------------------------------------------------
#  STUDENT GET ROUTES ------
#----------------- INDEX SQUAD OF STUDENTS ------
get '/students' do
  students = []
    @conn.exec("SELECT * FROM students ORDER BY student_id ASC") do |result|
      result.each do |student|
        students << student
      end
    end
    @students = students
    erb :indexstudents
end

#------------------------------------------
#----------------- STUDENTS IN SQUAD ------
get '/squads/:squad_id/students' do
  students = []
  id = params[:squad_id].to_i
     @conn.exec("SELECT * FROM students WHERE squad_id=$1", [id]) do |result|
      result.each do |student|
        students << student
      end
    end
    @students = students

     id = params[:squad_id].to_i
 
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
  
    @squad = squad[0]
   
    erb :studentsinsquad
end
#----------------- NEW STUDENT ------------------
get '/squads/:squad_id/students/new' do
   id = params[:squad_id].to_i
  
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
     
    @squad = squad[0]
  erb :newstudent
end
#----------------- SHOW STUDENT -----------------
get '/squads/:squad_id/students/:student_id' do
  id = params[:student_id].to_i
    
    student = @conn.exec("SELECT * FROM students WHERE student_id=$1", [id])
    
    @student = student[0]

  erb :showstudent
end


#----------------- EDIT STUDENT -----------------
get '/squads/:squad_id/students/:student_id/edit' do
    id = params[:student_id].to_i
  
  student = @conn.exec("SELECT * FROM students WHERE student_id=$1", [id])
     
    @student = student[0]


    id = params[:squad_id].to_i
  
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
     
    @squad = squad[0]

  erb :editstudent
end
#------------------------------------------------
#------------------------------------------------
#------------------------------------------------




 # ALTER TABLE students ADD CONSTRAINT squad_fk FOREIGN KEY (squad_Id) REFERENCES squads (id) ON DELETE NO ACTION;



#------------------------------------------------
 # POST ROUTES -------'CREATE'-----------------------
#------------------------------------------------
#-------------------- SQUAD CREATE ----------------------------
#------------------------------------------------
post '/squads' do
  @conn.exec("INSERT INTO squads (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])

  redirect '/squads'
end
#------------------------------------------------
#-------------------- STUDENT CREATE --------------------------
#------------------------------------------------
post '/squads/:squad_id/students' do
  id = params[:squad_id].to_i
  # binding.pry
  @conn.exec("INSERT INTO students (name, age, spirit_animal, squad_id) VALUES ($1, $2, $3, $4)", [params[:name], params[:age], params[:spirit_animal], id])
  
  redirect "/squads/#{id}"
end

#------------------------------------------------
#   PUT ROUTES -----'UPDATE'--------------------------
# -----------------------------------------------
#--------------------- SQUAD UPDATE ---------------------------
#------------------------------------------------
put '/squads/:squad_id' do
  id = params[:squad_id].to_i
  
  @conn.exec("UPDATE squads SET name = $1, mascot = $2 WHERE id = $3", [params[:name], params[:mascot], id])
  redirect '/squads'
end

#-----------------------------------------------
#--------------------- STUDENT UPDATE -------------------------
#------------------------------------------------
put '/squads/:squad_id/students/:student_id' do 
  id = params[:student_id].to_i
  
 
  squadid = params[:squad_id].to_i
  
  @conn.exec("UPDATE students SET name = $1, age = $2, spirit_animal = $3 WHERE student_id = $4", [params[:name], params[:age], params[:spirit_animal], id])
  redirect "/squads/#{squadid}/students"
end

#------------------------------------------------
# DELETE ROUTES ------'DESTROY'----------------------
# -----------------------------------------------
#------------------------------------------------
#----------------------- SQUAD DESTROY -------------------------
#------------------------------------------------
delete '/squads/:squad_id' do
  id = params[:squad_id].to_i
  @conn.exec("DELETE FROM squads WHERE id = $1", [id])
  redirect '/squads' 
end
#------------------------------------------------
# --------------------- STUDENT DESTROY ------------------------
#------------------------------------------------
delete '/squads/:squad_id/students/:student_id' do
  studentid = params[:student_id].to_i
  @conn.exec("DELETE FROM students WHERE student_id = $1", [studentid]) 
  id = params[:squad_id].to_i
  redirect "/squads/#{id}/students"
  
end
#------------------------------------------------









