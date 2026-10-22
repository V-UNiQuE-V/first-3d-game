extends Area3D

const SPEED = 20.0
const RANGE = 40.0

# how far bullet travelled - changes each frame
var travelled_dist = 0.0


func _physics_process(delta):
	# change bullet pos along z axis in 3D since bullet is opp. of the direction of axis we do (-ve) for it to forward in opp. dir.
	position += -transform.basis.z * SPEED * delta
	# player shoots bullets they accumulate which slow downs the game so we have to delete the bullet when reach limited range.
	
	# So, we inc the travelled_dist each frame once it's > range we delete the bullet.
	# travelled dist of bullet regardless of the dir.
	travelled_dist += SPEED * delta
	if travelled_dist > RANGE:
		# destroy the bullet
		queue_free()
