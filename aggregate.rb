class Aggregate
  attr_writer :x, :y, :active
  attr_writer :rot, :offset
  attr_reader :index, :rot
  
  def initialize( file, name, index, w, h )
    @segments = []
    @name = name
    
    for answer in File.readlines(file)
      components = answer.split(/\t/)
      @segments.push( { 'name'=>components[0], 'ratio'=>components[1].to_f, 'color'=>$app.color(rand(200)+55, 55) } )
    end
    @x = 0
    @y = 0
    @rot = 0
    @offset = 0
    @index = index
    @active = false
    @w = w
    @h = h
  end
  
  public
  
  def apply_transformations
    $app.translate( @x, @y+@h )
    $app.rotate @rot
    $app.translate( -@w/2, -@h-@offset )
  end
  
  def draw( draw_fills=true, draw_hashes=false, draw_label=true )
    $app.pushMatrix
    apply_transformations
    
    if draw_fills
      offset = 0
      for s in @segments
        $app.fill( s['color'] )
        $app.no_stroke
        $app.rect( 0, offset, @w, @h*s['ratio'] )
        offset += @h*s['ratio']
      end
    end
    
    if draw_hashes
      offset = 0
      $app.no_fill
      $app.stroke 127, 127
      for s in @segments
        $app.line( 0, @h*(offset+s['ratio']/2.0), @w, @h*(offset+s['ratio']/2.0) )
        offset += s['ratio']
      end
    end
    
    if draw_label
      val=""
      if contains_mouse?
        val = ": " + value_at( ($app.mouseY.to_f-screen_top)/@h.to_f )
      end
    
      $app.fill 51, 51, 102 unless @active
      $app.fill 153, 153, 204 if @active
      $app.translate(0, -10)
    
      $app.text( @name+val, 0, 0 )
    end
    
    $app.popMatrix
  end
  
  def value_at( point )
    #puts point.to_s + ", " + @segments.first['ratio'].to_s + ", " + @segments.first['name'].to_s
        
    currentPosition = 0
    for s in @segments
      currentPosition += s['ratio']
      if currentPosition > point
        return s['name'].to_s
      end
    end
    
    return point.to_s
  end
  
  def get_point( key )
    tx = @w/2
    ty = 0
    for s in @segments
      ty += s['ratio']
      if s['name'] == key
        ty -= s['ratio']/2
        break
      end
    end
    ty *= @h
    #apply rotation to end point
    $app.pushMatrix

    apply_transformations
    
    x = $app.modelX( tx, ty, 0 )
    y = $app.modelY( tx, ty, 0 )
    $app.popMatrix
    return Processing::PVector.new(x,y), get_color(key)
  end
  
  def get_color( key )
    return $app.color( rand(127), rand(55), rand(255), 127 )
  end
  
  def contains_mouse?
    #really only works when at 0 rotation
    return ($app.mouseX > screen_left and $app.mouseX < screen_right and $app.mouseY > screen_top and $app.mouseY < screen_bottom )
  end
  
  def screen_top
    return $app.modelY( @w/2, 0, 0 )
  end
  def screen_bottom
    return $app.modelY( @w/2, @h, 0 )
  end
  
  def screen_left
    return $app.modelX( 0, @y+@h/2, 0 )
  end
  def screen_right
    return $app.modelX( @w, @y+@h/2, 0 )
  end
end