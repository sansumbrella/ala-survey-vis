# Chart
require 'ruby-processing'
require 'aggregate'
require 'path'

class Chart < Processing::App
  
  load_libraries :opengl
  include_package "processing.opengl"
  
  def setup
    render_mode OPENGL
    hint ENABLE_OPENGL_4X_SMOOTH
    puts "New Chart"
    
    @chart_w = 100
    @chart_h = 200
    @start_index = 0
    @num_responses = 1
    @max_responses = 24
    @chart_spacer = 0
    @charts = []
    @paths = []
    @active_paths = []
    @charts.push( Aggregate.new( 'data/ages.tsv',     'age',  0,  @chart_w,          @chart_h ),
                  Aggregate.new( 'data/genders.tsv',  'gender',  1,  @chart_w,       @chart_h ),
                  Aggregate.new( 'data/races.tsv',    'race',  2,  @chart_w,         @chart_h ),
                  Aggregate.new( 'data/regions.tsv',  'region',  3,  @chart_w,       @chart_h ),
                  Aggregate.new( 'data/education.tsv','educ',  4,  @chart_w,           @chart_h ),
                  Aggregate.new( 'data/hours.tsv',    'hours',  5,  @chart_w,        @chart_h ),
                  Aggregate.new( 'data/web_amount.tsv', 'webstuff', 6,  @chart_w,    @chart_h ),
                  Aggregate.new( 'data/excitement.tsv', 'excitement', 7,  @chart_w,  @chart_h ),
                  Aggregate.new( 'data/satisfaction.tsv', 'satisfaction', 8,@chart_w,@chart_h )
                  )
    for i in 0..(@charts.length-1)
      @charts[i].x = i*(@chart_w+@chart_spacer)
      @charts[i].y = 100
      @charts[i].rot = 0
    end
    f = File.readlines('data/paths.tsv')
    f.each{ |s| @paths.push(Path.new(s)) }
    
    @active_paths = @paths.slice( @start_index, @num_responses )
    @active_paths.each{ |p| p.calculate(@charts,false) }
    smooth
    
    @label_font = loadFont("Caslon.vlw")
    text_font @label_font
    
  end
  
  def draw
    background 255
    
    next_path() if @active_paths.last.finished?
    @active_paths.each{ |p| p.calculate(@charts,false) }
    
    stroke 0, 127
    stroke_weight 1
    no_fill
#    @active_paths.each{ |p| p.draw(); p.step_forward }

    stroke 0, 127
    @charts.each{ |c| c.draw }
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

end

Chart.new :title => "Chart", :width => 1024, :height => 960