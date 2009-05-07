class Integrator
  attr_reader :value, :target
  attr_writer :target, :damping, :attraction
  
  def initialize( value, target )
    @value = value
    @target = target
    @vel = 0
    @damping = 0.65
    @attraction = 0.05
  end
  
  def step_forward
    @vel += (@target-@value)*@attraction
    @vel *= @damping
    @value += @vel
  end
  
end