using System.Collections.Generic;
using UnityEngine;

public class LevelGenerator : MonoBehaviour
{
    [Header("References")]
    [SerializeField] CameraController cameraController;
    [SerializeField] GameObject[] chunkPrefabs;
    [SerializeField] GameObject chunkcheckpointPrefabs;
    [SerializeField] Transform chunkParent;//這樣重複生成的時候會生成在chunkParent裡面，不會產生在外面很亂
    [SerializeField] ScoreManager scoreManager;//讓LevelGenerator有ScoreManager的資料

    [Header("Level Settings")]
    [Tooltip("數量開始")]
    [SerializeField] int startingChunksAmount = 12;
    [Tooltip("幾塊之後出現checkpoint")]
    [SerializeField] int checkpointChunkInterval = 8;
    [SerializeField] float chunkLength = 10f;
    [SerializeField] float moveSpeed = 8f;
    [SerializeField] float minMoveSpeed = 2f;
    [SerializeField] float maxMoveSpeed = 20f;
    [SerializeField] float minGravityZ = -22f;
    [SerializeField] float maxGravityZ = -2f;

    List<GameObject> chunks = new List<GameObject>();// 預設是空的（0 格）
    int chunkSpawned = 0;

    void Start()
    {
        SpawnStartingChunks();
    }

    void Update()
    {
        MoveChunks();
    }

    public void ChangeChunkMoveSpeed(float speedAmount)
    {
        float newMoveSpeed = moveSpeed + speedAmount;
        newMoveSpeed = Mathf.Clamp(newMoveSpeed, minMoveSpeed, maxMoveSpeed);

        if (newMoveSpeed != moveSpeed)//最slow速度，不能再更低
        {
            moveSpeed = newMoveSpeed;

            float newGravityZ = Physics.gravity.z - speedAmount;
            newGravityZ = Mathf.Clamp(newGravityZ, minGravityZ, maxGravityZ);
            Physics.gravity = new Vector3(Physics.gravity.x, Physics.gravity.y, newGravityZ);
            //這邊是同步調整在Project Setting>Physics Setting的Gravity

            cameraController.ChangeCameraFOV(speedAmount);
        }
    }

    void SpawnStartingChunks()//生成幾塊地板
    {
        for (int i = 0; i < startingChunksAmount; i++)
        {
            SpawnChunk();
        }
    }

    void SpawnChunk()//生成地板
    {
        float spawnPositionZ = CalculationSpawnPositionZ();
        Vector3 chunkSpawnPos = new Vector3(transform.position.x, transform.position.y, spawnPositionZ);
        GameObject chunkToSpawn = ChooseChunkToSpawn();
        GameObject newChunkGO = Instantiate(chunkToSpawn, chunkSpawnPos, Quaternion.identity, chunkParent);
        chunks.Add(newChunkGO); //使用list要用ADD。 固定用法
        Chunk newChunk = newChunkGO.GetComponent<Chunk>();//讓newChunkGO拿到腳本的控制權
        newChunk.Init(this, scoreManager);//讓 Chunk 知道誰是 LevelGenerator和scoreManager

        chunkSpawned++;
    }

    private GameObject ChooseChunkToSpawn()
    {
        GameObject chunkToSpawn;
        if (chunkSpawned % checkpointChunkInterval == 0 && chunkSpawned != 0)
        {
            chunkToSpawn = chunkcheckpointPrefabs;
        }
        else
        {
            chunkToSpawn = chunkPrefabs[Random.Range(0, chunkPrefabs.Length)];//隨機選擇chunk prefab
        }

        return chunkToSpawn;
    }

    float CalculationSpawnPositionZ()//計算地板要往前位置生成
    {
        float spawnPositionZ;
        if (chunks.Count == 0)
        {
            spawnPositionZ = transform.position.z;
        }
        else
        {
            spawnPositionZ = chunks[chunks.Count - 1].transform.position.z + chunkLength;
        }

        return spawnPositionZ;
    }

    void MoveChunks()//每幀把第 i 塊地板 沿 -Z 方向 往後推
    {
        for (int i = 0; i < chunks.Count; i++)
        {
            GameObject chunk = chunks[i];
            chunk.transform.Translate(-transform.forward * (moveSpeed * Time.deltaTime));

            if (chunk.transform.position.z <= Camera.main.transform.position.z - chunkLength)
            {
                chunks.Remove(chunk); //使用list要用Remove。 固定用法
                Destroy(chunk);
                SpawnChunk();
            }
        }
    }
}
