class CompoundCurve
  
  def initialize( points, smoothness=24 )
    @points = []
    for i in 0..points.length-1
      unless points.length-4 < i
        p1 = points[i]
        p2 = points[i+1]
        p3 = points[i+2]
        p4 = points[i+3]
        for step in 0..smoothness
          x = $app.curvePoint( p1.x, p2.x, p3.x, p4.x, step/smoothness.to_f )
          y = $app.curvePoint( p1.y, p2.y, p3.y, p4.y, step/smoothness.to_f )
          @points.push( Processing::PVector.new( x, y ))
        end
      end
    end
  end
  
  def draw(t)
    $app.begin_shape
    @points.each_index{ |i| $app.vertex( @points[i].x, @points[i].y ) unless i.to_f/@points.length.to_f > t }
    $app.end_shape
  end
  
end