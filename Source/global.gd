extends Node

# Global variables
var adjacent: int = 4
var radius: int = 100
var power : int = 4
var axises : Array = []
var size : int = 0
var force_euclidean : bool = false

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------
func initiate():
	axises = get_axises(adjacent)

func get_axises(vertices):
	var current = 0
	var angles = []
	for i in range(vertices):
		angles.append(current)
		current += 2 * PI / vertices
	return angles
