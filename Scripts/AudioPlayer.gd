extends Node

#Gets the sample player node
onready var samplePlayer = get_node("SamplePlayer")
var soundID

#This func takes in which type of sound must be played and randomly chooses which version - Nice!
func play(sampleName):
	randomize()
	#decides which version will be played
	soundID = round(rand_range(1,2))
	#sets the final string to be the type plus the version
	var realSampleName = str(sampleName) + str(soundID)
	#print(realSampleName)
	#plays the sound effect
	samplePlayer.play(realSampleName)
	
	