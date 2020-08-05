extends KinematicBody

func _ready():
	pass # Replace with function body.
	
#why does dropping move forward
#get better formula for cl and cd vs alpha
var g = -9.81 #m/s
var speed = -200
var velocity = Vector3(0,0,speed)
var dir = Vector3(0,0,0)
var force = Vector3(0,0,0)

var acc = Vector3(0,0,0)
var CL = 0
var L = 0
var CD = 0
var D = 0
var alpha = 0
var beta = 0
# Called when the node enters the scene tree for the first time.
var vela = Vector3(0,0,0)
	
var weight = 1157 * g
var S_wing = 16.17 #in m2

var T = 7000
var am = .7#angular speed
#forces in airplane frame of reference
var N = 0
var A = 0
var S = 0
var G_local = Vector3(0,0,0)
var heading = 0

func _process(delta):

# warning-ignore:shadowed_variable
# warning-ignore:unused_variable
# warning-ignore:shadowed_variable
	var acc = Vector3(0,0,0)
	if Input.is_key_pressed(KEY_W):
		rotate_object_local(Vector3(1, 0, 0), delta*am*.3)
	if Input.is_key_pressed(KEY_S):
		rotate_object_local(Vector3(1, 0, 0), -delta*am*.3)
	if Input.is_key_pressed(KEY_Q):
		rotate_object_local(Vector3(0, 1, 0), delta*am)
	if Input.is_key_pressed(KEY_E):
		rotate_object_local(Vector3(0, 1, 0), -delta*am)
	if Input.is_key_pressed(KEY_A):
		rotate_object_local(Vector3(0, 0, 1), -delta*am)
	if Input.is_key_pressed(KEY_D):
		rotate_object_local(Vector3(0, 0, 1), delta*am)
	if Input.is_key_pressed(KEY_I):
		T+=100*delta
	if Input.is_key_pressed(KEY_K):
		T-=100*delta
	
	if Input.is_action_just_pressed("ui_accept"): #fix to do for key H
		$"../HUD/debug".visible = not $"../HUD/debug".visible #toggle
	if T < 0:
		T = 0
	
		

	#variation of drag with sideslip?
	#should alpha change when rolling (with an already existing pitch)
	dir = get_transform().basis.z
	#velocity = dir * speed
	
	
	vela = transform.basis.xform_inv(velocity)
	alpha =  atan2(-vela.y, vela.z)
	beta = atan2(vela.x,vela.length())
	if abs(rad2deg(beta)) > 5:
		if beta < 0:
			rotate_object_local(Vector3(0, 1, 0), -delta*am*.3)
		elif beta > 0:
			rotate_object_local(Vector3(0, 1, 0), delta*am*.3)
		
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector3(0,1,0))
	
	


	
	
#	given an aircraft representred by 3 axis
#	and velocity vector. how to find angle of attack
	force = Vector3(0,0,0)	
	
	CL = 2*3.14*alpha #TODO : model stall
	if alpha > deg2rad(15) and alpha < deg2rad(30):
		CL = 2*3.14*deg2rad(15) - 2*3.14*(alpha-deg2rad(15))
	if alpha < deg2rad(-15) and alpha > deg2rad(-30):
		CL = 2*3.14*deg2rad(-15) - 2*3.14*(alpha-deg2rad(-15))
	
	CD = .025 + pow(abs(rad2deg(alpha)),2)/2300 
	L = .5 * 1.225 * S_wing * velocity.length() * velocity.length()* CL
	D = .5 * 1.225 * S_wing * velocity.length() * velocity.length()* CD
	N = L*cos(alpha) + D*sin(alpha)
	A = D*cos(alpha) - L*sin(alpha)
	A = -A
	A = A + T
	S = 0 #side force. from yaw. aileron not related here
	
	
	
	
	#aileron force is manifested in the global frame
	
	#convert NSA to earth frame
	force = Vector3(S,N,A)
	G_local = -force.y/(weight)  #plus one because formula, other for gravity
	force = transform.basis.xform(force)  #inverse?
	
	#convert forces to acceleratoin
	acc = g*force/weight
	acc.y+=g
	#make acceleration affect velocity (multiply by delta)
	velocity += acc*delta
	
	

	$"../HUD/aoa".text = "AOA\n" + str(rad2deg(alpha)) + "\nBeta\n" + str(rad2deg(beta))
	#$"../HUD/aoa".text = "N A S\n" + str(S) + "\n" + str(N) + "\n" + str(A)
	#$"../HUD/airspeed".text = "AOA\n" + str((velocity.x)) + "\n" + str(velocity.y) + "\n" + str(velocity.z)
	$"../HUD/airspeed".text = "AIRSPEED\n" + str(stepify(velocity.length(),.1)) + " m/s"
	$"../HUD/altitude".text = "ALT\n" + str(ceil(translation.y)) + " m"
	$"../HUD/vs".text = "VS\n" + str(stepify(velocity.y,.1)) + " m/s"
	$"../HUD/thrust".text = "THRUST\n" + str(stepify(T,.1)) + " N"
	$"../HUD/gforce".text = str(G_local) + " G"
	$"../HUD/heading".rotation = -atan2(dir.z,dir.x)
	$"../HUD/debug".text = "AOA in radian  : \n" + str(alpha)
#	$"../HUD/blackout".modulate.a = G_local - 4 #should improve after implementing
#	$"../HUD/redout".modulate.a = -G_local  -3  #moments and all
#
	transform = transform.orthonormalized() 
	
