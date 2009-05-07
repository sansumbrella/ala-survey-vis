# Animated Curve

class AnimatedCurve < Processing::App

  def setup
    no_fill
    smooth
    ellipse_mode CENTER
    @t = 0
    @v = 0.005
    @curve = Curve.new( PVector.new(5, 26), PVector.new(5, 26), PVector.new(73, 24), PVector.new(73, 61), 60 )
  end
  
  def draw
    background 255
    scale(5.0)
    stroke 0
    beginShape
      curve_vertex 5, 26
      curve_vertex 5, 26
      curve_vertex 73, 24
      curve_vertex 73, 61
    endShape
    
    if @t > 1 or @t < 0
      @v *=-1
    end
    @t += @v
    x = curvePoint(5, 5, 73, 73, @t)
    y = curvePoint(26, 26, 24, 61, @t)
    ellipse(x, y, 5, 5)
    
    stroke 250, 0, 0
    @curve.draw(@t)
  end
  
end

class Curve
  
  def initialize( p1, p2, p3, p4, smoothness=50 )
    @points = []
    for i in 0..smoothness
      x = $app.curvePoint( p1.x, p2.x, p3.x, p4.x, i/smoothness.to_f )
      y = $app.curvePoint( p1.y, p2.y, p3.y, p4.y, i/smoothness.to_f )
      puts x.to_s + ", " + y.to_s
      @points.push( Processing::PVector.new( x, y ))
    end
  end
  
  def draw( t )
    $app.begin_shape
    @points.each_index{ |i| $app.vertex( @points[i].x, @points[i].y ) unless i.to_f/@points.length.to_f > t }
    $app.end_shape
  end
  
end

AnimatedCurve.new :title => "Animated Curve", :width => 600, :height => 600