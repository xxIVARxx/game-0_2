extends RayCast3D

@onready var beam_mesh = $BeamMesh
@onready var end_particles = $EndParticles
@onready var beam_particles = $BeamParticles


var tween: Tween
var beam_radius: float = 0.03

var from : Vector3
var to : Vector3



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	visible = false
	if Input.is_action_pressed("laser"):
		visible = true 
		activate(3)
	else:
		#deactivate(1)
		visible = false

	
	var cast_point
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		from = cast_point 

		beam_mesh.mesh.height = cast_point.y
		beam_mesh.position.y = cast_point.y/2
		
		end_particles.position.y = cast_point.y
		
		beam_particles.position.y = cast_point.y/2
		
		var particle_amount = snapped(abs(cast_point.y) * 50,1)
		
		if particle_amount > 1:
			beam_particles.amount = particle_amount
			particle_amount = to

		else:
			beam_particles.amount = 1
			
			beam_particles.process_material.set_emission_box_extents(
				Vector3(beam_mesh.mesh.top_radius,abs(cast_point.y)/2,beam_mesh.mesh.top_radius))
			
			
func activate(time: float):
	tween = get_tree().create_tween()
	visible = true
	beam_particles.emitting = true
	end_particles.emitting = true
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh,"top_radius",beam_radius, time)
	tween.tween_property(beam_mesh.mesh,"bottom_radius",beam_radius, time)
	tween.tween_property(beam_particles.process_material,"scale_min",1,time)
	tween.tween_property(end_particles.process_material,"scale_min",1,time)
	await tween.finished
	
	
func deactivate(time: float):
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh,"top_radius",0.0, time)
	tween.tween_property(beam_mesh.mesh,"bottom_radius",0.0, time)
	tween.tween_property(beam_particles.process_material,"scale_min",0.0,time)
	tween.tween_property(end_particles.process_material,"scale_min",0.0,time)
	await tween.finished
	visible = false
	beam_particles.emitting = false
	end_particles.emitting = false
