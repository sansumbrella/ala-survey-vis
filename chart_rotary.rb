# Chart
require 'ruby-processing'
require 'integrator'
require 'aggregate'
require 'path'

class Chart < Processing::App
  
  load_libraries :video, :opengl
  import 'processing.video.MovieMaker'
  include_package "processing.opengl"
  
  def setup
    render_mode OPENGL
    hint ENABLE_OPENGL_4X_SMOOTH
    puts "New Chart"
    @theta = Integrator.new(0,0)
    @current_chart = 0
    @do_play = true
    
    @do_record = false
#    @mm = MovieMaker.new( self, width, height, "drawing.mov", 30, MovieMaker::ANIMATION, MovieMaker::HIGH )
    @chart_w = 24
    chart_h = 210
    @start_index = 29990
    @num_responses = 36
    @max_responses = 36
    
    @label_font = loadFont("Caslon.vlw")
    @body_font = loadFont("Body.vlw")
    
    @charts = []
    @paths = []
    @active_paths = []
    @charts.push( Aggregate.new( 'data/ages.tsv', "Age",      0,  @chart_w, chart_h ),
                  Aggregate.new( 'data/genders.tsv', "Gender",    1,  @chart_w, chart_h ),
                  Aggregate.new( 'data/races.tsv', "Race/Ethnicity",      2,  @chart_w, chart_h ),
                  Aggregate.new( 'data/regions.tsv', "Global Region",    3,  @chart_w, chart_h ),
                  Aggregate.new( 'data/education.tsv', "Education Level",  4,  @chart_w, chart_h ),
                  Aggregate.new( 'data/hours.tsv',    "Hours/week",      5,  @chart_w, chart_h ),
                  Aggregate.new( 'data/web_amount.tsv', "Is it online", 6,  @chart_w, chart_h ),
                  Aggregate.new( 'data/excitement.tsv', "Excited", 7,  @chart_w, chart_h ),
                  Aggregate.new( 'data/satisfaction.tsv', "Satisfied", 8,@chart_w, chart_h )
                  )    
    rot = 0
    @r_step = (3.1415*2.0)/(@charts.length).to_f
    for i in 0..(@charts.length-1)
      @charts[i].x = 0
      @charts[i].y = -chart_h
      @charts[i].offset = 50
      @charts[i].rot = rot
      rot += @r_step
    end
    @charts.first.active = true
    
    f = File.readlines('data/paths.tsv')
    f.each{ |s| @paths.push(Path.new( :sequence_str=>s)) }
    
    @active_paths = @paths.slice( @start_index, @num_responses )
    @active_paths.each{ |p| p.calculate(@charts) }
    smooth
    frame_rate 30
    background 255
  end
  
  def draw
    no_stroke
    fill 255, 127
    rect 0, 0, width, height
    @theta.step_forward
    
    next_path() if @active_paths.last.finished?
    @active_paths.each{ |p| p.calculate(@charts) }
    
    #let's make an image for this, instead
=begin
    fill 0
    text_font @label_font
    text( "I wonder if this is who I want to be.", 10, 24 )
    text_font @body_font
    text( "Data from the A List Apart 2008 Web Survey.", 10, 44 )
=end
    
    push_matrix
    translate width/2, height/2
    rotate @theta.value
    
    stroke_weight 1
    no_fill
    @active_paths.each{ |p| p.draw }
    @active_paths.each{ |p| p.step_forward } if @do_play
    
    stroke 0, 20
    stroke_weight 1
    text_font @label_font
    @charts.each{ |c| c.draw(false,true,true) }
    
    pop_matrix
    
    @active_paths.last.draw_info(@label_font, @body_font)
    #prevent asynchronous changes to the @active_paths
    next_path if @do_next_path
    prev_path if @do_prev_path
    
    if( @do_save )
      save_frame "screenshots/sketchcapture_####.png"
      @do_save = false
    end
    if @do_record==true
      @mm.add_frame
    end
  end
  
  
  def chart_width
    return (@charts.length*( @chart_spacer + @chart_w ))
  end
  
  def show_next
    @theta.target -= @r_step
    change_label(1)
  end
  
  def show_prev
    @theta.target += @r_step
    change_label(-1)
  end
  
  def change_label( inc )
    @charts[@current_chart].active = false
    @current_chart += inc
    if @current_chart > @charts.length-1
      @current_chart=0
    end
    if @current_chart < 0
      @current_chart = @charts.length-1
    end
    @charts[@current_chart].active = true
  end
  
  def next_path
    @do_next_path = false
    unless @num_responses >= @max_responses
      @num_responses += 1
    else
      @start_index+=1 unless @start_index+@num_responses == @paths.length-1
    end
    if @start_index + @num_responses >= @paths.length-1
      @start_index = 0
    end
    @active_paths.first.discard_points #memory management
    @active_paths.last.jump_to_end
    @active_paths = @paths.slice( @start_index, @num_responses )
    @active_paths.last.reset unless @display_finished_shapes
  end
  
  def prev_path
    @do_prev_path = false
    @start_index-=1 unless @start_index == 0
    @active_paths.last.discard_points #memory management
    @active_paths = @paths.slice( @start_index, @num_responses )
    @active_paths.last.reset unless @display_finished_shapes
  end
  
  def mousePressed( event )
    puts event.to_s
    spacer = @chart_w/2
    show_next if mouseX > width/2+spacer
    show_prev if mouseX < width/2-spacer
  end

  def keyPressed( value )
    #This happens asynchronously with draw
    #don't directly change the contents of any other objects within here, it could break the draw loop
    puts "KEY PRESSED: " + value.to_s
    puts "keyChar.to_s " + value.keyChar.to_s
    case value.keyChar
    when 114
      @do_record = false
      @mm.finish
      exit
    when 115
      @do_save = true
    end
      
    case value.keyCode
    when 80 #'p'
      @do_play = !@do_play
    when 39 # right arrow
      show_next
    when 61 # '='
      show_next
    when 37 # left arrow
      show_prev
    when 45 # '-'
      show_prev
    when 38 #up arrow
      @do_next_path = true
    when 91 # ']'
      @do_next_path = true
    when 40 #down arrow
      @do_prev_path = true
    when 93 # '['
      @do_prev_path = true
    when 48 # '0'
=begin      
#this has crazy consequences I'm not ready for yet
      @display_finished_shapes = !@display_finished_shapes
      @do_play = false if @display_finished_shapes
=end
    end
  end

end

Chart.new :title => "Chart", :width => 1024, :height => 720