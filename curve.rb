class Curve
  
  def initialize( p1, p2, p3, p4, smoothness=20 )
    @points = []
    for i in 0..smoothness
      x = $app.curvePoint( p1.x, p2.x, p3.x, p4.x, i/smoothness.to_f )
      y = $app.curvePoint( p1.y, p2.y, p3.y, p4.y, i/smoothness.to_f )
      @points.push( Processing::PVector.new( x, y ))
    end
  end
  
  def draw( t )
    $app.begin_shape
    @points.each_index{ |i| $app.vertex( @points[i].x, @points[i].y ) unless i.to_f/@points.length.to_f > t }
    $app.end_shape
  end
  
end