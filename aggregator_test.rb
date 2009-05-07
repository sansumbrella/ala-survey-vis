# Aggregator Test
require 'aggregate'

class AggregatorTest < Processing::App
  load_libraries :opengl
  include_package "processing.opengl"
  
  def setup
    render_mode OPENGL
    @chart_w = 40
    @chart_h = 300
    @chart_spacer = 50
    @charts = []
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
    @charts.each_index do |i|
      @charts[i].x = 150*i #i*(@chart_w+@chart_spacer)
      @charts[i].y = 150
      @charts[i].offset = 50
      @charts[i].rot = 3.1415/@charts.length * 0
    end
    @label_font = loadFont("Caslon.vlw")
    text_font @label_font
    smooth
  end
  
  def draw
    background 255
    @charts.each{ |c| c.draw(true, true, true); }
  end
  
end

AggregatorTest.new :title => "Aggregator Test", :width => 1024, :height => 768