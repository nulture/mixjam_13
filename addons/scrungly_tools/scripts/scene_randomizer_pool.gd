
## Provides a set of scenes and settings for [SceneRandomizer2D] or [SceneRandomizer3D].
@tool class_name SceneRandomizerPool extends Resource

## If set, this will assign a random angle to the selected scene's rotation (2D only).
@export var random_angle : bool = false

## If set, this will assign a random pitch to the selected scene's rotation (3D only).
@export var random_pitch : bool = false

## If set, this will assign a random yaw to the selected scene's rotation (3D only).
@export var random_yaw : bool = true

## If set, this will assign a random roll to the selected scene's rotation (3D only).
@export var random_roll : bool = false

## Set of scenes from which to choose.
@export var contents : Array[PackedScene]
