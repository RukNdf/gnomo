extends Node3D

#list of spawn positions
func getSpawnPositions():
	return [$EnemySpawnerUL.position, $EnemySpawnerLL.position, $EnemySpawnerUR.position, $EnemySpawnerLR.position, $EnemySpawnerC.position]
	
