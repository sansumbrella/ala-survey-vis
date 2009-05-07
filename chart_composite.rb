# Chart
require 'ruby-processing'
require 'integrator'
require 'aggregate'
require 'path'

class ChartComposite < Processing::App
  
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
    @start_index = 20000
    @num_responses, @max_responses = 72, 72
    
    @label_font = loadFont("Caslon.vlw")
    @body_font = loadFont("Body.vlw")
    
    @charts = []
    @paths = []
    @active_paths = []
    
    @lin_charts = []
    @lin_paths = []
    
    chart_w = 18
    r_chart_h = 150
    @rx, @ry = width-280, 230
    
    @charts.push( Aggregate.new( 'data/ages-r.tsv', "Age",      0,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/genders.tsv', "Gender",    1,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/races.tsv', "Race/Ethnicity",      2,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/regions.tsv', "Global Region",    3,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/education-r.tsv', "Education Level",  4,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/hours-r.tsv',    "Hours/week",      5,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/web_amount-r.tsv', "Is it online", 6,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/excitement-r.tsv', "Excited", 7,  chart_w, r_chart_h ),
                  Aggregate.new( 'data/satisfaction-r.tsv', "Satisfied", 8,chart_w, r_chart_h )
                  )
    chart_w = 30
    chart_h = 240
    @lin_charts.push( Aggregate.new( 'data/ages-r.tsv', "Age",      0,  chart_w, chart_h ),
                  Aggregate.new( 'data/genders.tsv', "Gender",    1,  chart_w, chart_h ),
                  Aggregate.new( 'data/races.tsv', "Race/Ethnicity",      2,  chart_w, chart_h ),
                  Aggregate.new( 'data/regions.tsv', "Global Region",    3,  chart_w, chart_h ),
                  Aggregate.new( 'data/education-r.tsv', "Education Level",  4,  chart_w, chart_h ),
                  Aggregate.new( 'data/hours-r.tsv',    "Hours/week",      5,  chart_w, chart_h ),
                  Aggregate.new( 'data/web_amount-r.tsv', "Is it online", 6,  chart_w, chart_h ),
                  Aggregate.new( 'data/excitement-r.tsv', "Excited", 7,  chart_w, chart_h ),
                  Aggregate.new( 'data/satisfaction-r.tsv', "Satisfied", 8,chart_w, chart_h )
                  )
    
    rot = 0
    @r_step = (3.1415*2.0)/(@charts.length).to_f
    
    @charts.each_index do |i|
      @charts[i].y = -r_chart_h
      @charts[i].offset = 30
      @charts[i].rot = rot
      rot += @r_step
    end
    
    total_width = chart_w*@lin_charts.length
    spacer = (width-total_width)/@lin_charts.length.to_f
    
    @lin_charts.each_index do |i|
      @lin_charts[i].x = (chart_w+spacer)*i + chart_w/2.0 + 20
      @lin_charts[i].y = height - chart_h - 20
    end
    
    @charts.first.active = true
    
    f = File.readlines('data/paths.tsv')
    f.each do |s|
      @paths.push(Path.new( :sequence_str=>s ) )
    end
    
    @active_paths = @paths.slice( @start_index, @num_responses )
    @lin_paths = []
    @active_paths.each do |p|
      @lin_paths.push p.clone
    end
    
    smooth
    frame_rate 30
    background 255
  end
  
  def draw
    background 0
    @theta.step_forward
    
    next_path() if @active_paths.last.finished?
    @active_paths.each{ |p| p.calculate(@charts) }
    @lin_paths.each{ |p| p.calculate(@lin_charts, false) }
    
    push_matrix
    translate @rx, @ry
    rotate @theta.value
    
    stroke_weight 1
    no_fill
    @active_paths.each do |p|
      p.draw
      p.step_forward if @do_play
    end
    
    stroke 0, 20
    stroke_weight 1
    text_font @label_font
    @charts.each{ |c| c.draw(false,true,true) }
    
    pop_matrix

    @lin_charts.each{ |c| c.draw }
    no_fill
    @lin_paths.each do |p|
      p.draw
      p.step_forward if @do_play
    end
    
    push_matrix
    translate 20, 40
    fill 153, 204, 255
    text_font @label_font
    text( "Viewing Path #{@start_index} of #{@paths.length}", 0, 0)
    
    push_matrix
    translate 100, 120
    stroke_weight 1
    scale 0.6, 0.6
    @charts.each{ |c| c.draw(false,true,false) }
    no_stroke
    @active_paths.last.draw_shape(:fill=>true)
    pop_matrix
    
    translate 240, 30
    fill 0, 102, 153
    text_font @body_font
    @active_paths.last.draw_info
    pop_matrix
    
    #prevents asynchronous changes to the @active_paths
    next_path if @do_next_path
    prev_path if @do_prev_path
    
    if @do_save
      save_frame "screenshots/sketchcapture_####.png"
      @do_save = false
    end
    if @do_record==true
      @mm.add_frame
    end
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
    
    @lin_paths.shift.discard_points
    @lin_paths.last.jump_to_end
    @lin_paths.push @active_paths.last.clone
    @lin_paths.last.reset
  end
  
  def prev_path
    @do_prev_path = false
    @start_index-=1 unless @start_index == 0
    @active_paths.last.discard_points #memory management
    @active_paths = @paths.slice( @start_index, @num_responses )
    @active_paths.last.reset unless @display_finished_shapes
    
    @lin_paths.pop.discard_points
    @lin_paths.push @active_paths.last.clone
    @lin_paths.last.reset
  end
  
  def mousePressed( event )
    puts event.to_s
    spacer = 220
    show_prev if ( mouseX > @rx-spacer and mouseX < @rx and mouseY < @ry + spacer )
    show_next if ( mouseX > @rx and mouseX < @rx+spacer and mouseY < @ry + spacer )
  end

  def keyPressed( value )
    #This happens asynchronously with draw
    #don't directly change the contents of any other objects within here, it could break the draw loop
    puts "KEY PRESSED: #{value.to_s}"
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
    when 91 # '['
      @do_prev_path = true
    when 40 #down arrow
      @do_prev_path = true
    when 93 # ']'
      @do_next_path = true
    when 48 # '0'
=begin      
#this has crazy consequences I'm not ready for yet
      @display_finished_shapes = !@display_finished_shapes
      @do_play = false if @display_finished_shapes
=end
    end
  end

end

ChartComposite.new :title => "Chart", :width => 1024, :height => 768