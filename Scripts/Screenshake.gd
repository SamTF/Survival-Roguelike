extends Camera2D

#Controls how much the camera will shake
var magnitude = 0
#Controls for how long the camera will shake
var timeLeft = 0
#Tracks if the camera is already shaking to prevent the shake func from being called more than once in a row
var isShaking = false

#This func shakes the screen
#newMagnitude states how much the camera will shake and lifetime states for how long it will shake
func shake(newMagnitude, lifetime):
	#If the current magnitude is bigger than the new one, then the new one will be ignored and the current one will be kept
	if magnitude > newMagnitude: return
	
	magnitude = newMagnitude
	timeLeft = lifetime
	
	#if the camera is already shaking, then the rest of the func won't be called
	if isShaking: return
	#If not, ttates that the camera is shaking
	isShaking = true
	
	#Runs this loop until the timer runs out
	while timeLeft > 0:
		var pos = Vector2()
		#Generates a random new X and Y value for the camera within the magnitude range given
		pos.x = rand_range(-magnitude, magnitude)
		pos.y = rand_range(-magnitude, magnitude)
		#Sets the camera's position to the random values, causing a shaking effect
		set_pos(pos)
		#decreases the timer using delta time
		timeLeft -= get_process_delta_time()
		#waits for the next frame before running the rest of the code
		yield(get_tree(), "idle_frame")
	
	#Resets the camera's pos, the isShaking, and the magnitude once the loop is over
	set_pos(Vector2(0,0))
	isShaking = false
	magnitude = 0
