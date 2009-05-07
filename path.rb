require 'compound_curve'

class Path
  def initialize( args={} )
    if args[:sequence]
      @sequence = args[:sequence]
    else
      @sequence = args[:sequence_str].split(/\t/)
      @sequence.each do |s|
        s.strip!
      end
    end
    @t_max = 1.15
    @t = @t_max
    @vel = 0.009
  end
  
  def clone
    return Path.new( :sequence=>@sequence )
  end
  
  def draw()    
    if finished?
      draw_shape(:stroke=>true)
    else
      $app.stroke 180, 0, 0
      $app.stroke_weight 3
      @curve.draw(@t)
    end
  end
  
  def draw_shape( args={} )
    $app.beginShape()
    @vertices.each_index do |i|
      $app.stroke @colors[i] if args[:stroke]
      $app.fill @colors[i] if args[:fill]
      $app.curveVertex( @vertices[i].x, @vertices[i].y )
    end
    $app.endShape()
  end
  
  def draw_info()
    y = 0
    for s in @sequence
      $app.text( s.to_s, 0, y )
      y += 18
    end
  end
  
  def step_forward
    @t += @vel unless @t > @t_max
  end
  
  def jump_to_end
    @t = @t_max
  end
  
  def reset
    @t = 0
  end
  
  def ready?
    return @curve != nil
  end
  
  def discard_points
    #otherwise we'll run out of memory when ~30k of these exist
    @vertices = nil
    @curve = nil
  end
  
  def calculate( charts, doloop=true )
    if( @vertices == nil )
      @vertices, @colors = [], []
      v, c = charts.first.get_point( @sequence[ charts.first.index ] )
      @vertices.push v
      @colors.push c
      for c in charts:
        v, col = c.get_point( @sequence[ c.index ] )
        @vertices.push( v )
        @colors.push( col )
      end
      if doloop
        v, c = charts.first.get_point( @sequence[ charts.first.index ] )
        @vertices.push v
        @colors.push c
        v, c = charts[1].get_point( @sequence[ charts[1].index ] )
        @vertices.push v
        @colors.push c
      else
        v, c = charts.last.get_point( @sequence[ charts.last.index ] )
        @vertices.push v
        @colors.push c
      end
      
      @curve = CompoundCurve.new( @vertices )
    end
  end
  
  def finished?
    return @t >= @t_max
  end  
end