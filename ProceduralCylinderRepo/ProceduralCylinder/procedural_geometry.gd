extends MeshInstance3D

@export var segments: int = 16
@export var height: float = 2.0
@export var radius: float = 1.0
@export var slices: int = 4
@export var bulge: float = 0.0

func _ready():
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, create_circle_surface(radius, height/2, true))
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, create_circle_surface(radius, -height/2, false))
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, create_mantle_surface(radius, height, segments, slices, bulge))

func create_circle_surface(radius: float, y: float, top: bool) -> Array:
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var norms = PackedVector3Array()
	var indices = PackedInt32Array()
	var alpha = 2.0 * PI / segments
	var normal_y = 1 if top else -1
	for i in range(segments):
		var x = radius * cos(i * alpha)
		var z = radius * sin(i * alpha)
		verts.push_back(Vector3(x, y, z))
		norms.push_back(Vector3(0, normal_y, 0))
	verts.push_back(Vector3(0, y, 0))
	norms.push_back(Vector3(0, normal_y, 0))
	var center_index = verts.size() - 1
	for i in range(segments):
		if top:
			indices.push_back(i)
			indices.push_back((i+1) % segments)
			indices.push_back(center_index)
		else:
			indices.push_back(i)
			indices.push_back(center_index)
			indices.push_back((i+1) % segments)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_INDEX] = indices
	return arr

func create_mantle_surface(radius: float, height: float, segments: int, slices: int, bulge: float) -> Array:
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var norms = PackedVector3Array()
	var indices = PackedInt32Array()
	var alpha = 2.0 * PI / segments
	for s in range(slices+1):
		var t = float(s) / slices
		var y = -height/2 + t*height
		var r = radius * (1 + bulge * sin(PI * t))
		for i in range(segments):
			var x = r * cos(i*alpha)
			var z = r * sin(i*alpha)
			verts.push_back(Vector3(x, y, z))
			norms.push_back(Vector3(cos(i*alpha), 0, sin(i*alpha)))
	for s in range(slices):
		for i in range(segments):
			var curr = s*segments + i
			var next = s*segments + (i+1) % segments
			var top = (s+1)*segments + i
			var top_next = (s+1)*segments + (i+1) % segments
			indices.push_back(curr)
			indices.push_back(next)
			indices.push_back(top)
			indices.push_back(next)
			indices.push_back(top_next)
			indices.push_back(top)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_INDEX] = indices
	return arr

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		rotation.y += PI * delta
	if Input.is_action_pressed("ui_right"):
		rotation.y -= PI * delta
	if Input.is_action_pressed("ui_up"):
		rotation.x += PI * delta
	if Input.is_action_pressed("ui_down"):
		rotation.x -= PI * delta
