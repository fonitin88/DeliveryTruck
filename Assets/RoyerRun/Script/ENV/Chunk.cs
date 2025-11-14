
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;


public class Chunk : MonoBehaviour
{
    [SerializeField] GameObject fencePrefab;
    [SerializeField] GameObject ApplePrefab;
    [SerializeField] GameObject coinPrefab;

    [SerializeField] float appleSpawnChance = 0.3f;
    [SerializeField] float coinSpawnChance = 0.5f;
    [SerializeField] float coinSeparationLength = 2f;//coin的間距

    //定義了三個陣列,可以生成 fence（柵欄）的 X 座標.出現在這三條固定的位置之一
    [SerializeField] float[] lanes = { -2.5f, 0f, 2.5f };

    List<int> availableLanes = new List<int> { 0, 1, 2 };//可以用的車道編號清單

    LevelGenerator levelGenerator;
    ScoreManager scoreManager;

    void Start()
    {
        SpawnFences();
        SpawnApples();
        SpawnCoins();
    }

    public void Init(LevelGenerator levelGenerator, ScoreManager scoreManager)
    {
        this.levelGenerator = levelGenerator;
        this.scoreManager = scoreManager;
    }

    void SpawnFences()
    {
        int fenceToSpawn = Random.Range(0, lanes.Length);//隨機挑出 0~2 個柵欄

        for (int i = 0; i < fenceToSpawn; i++)//隨機生成柵欄
        {
            if (availableLanes.Count <= 0) break;
            int selectedLane = GetRandomAvailableLaneIndex();

            Vector3 spawnPosition = new Vector3(lanes[selectedLane], transform.position.y, transform.position.z);
            Instantiate(fencePrefab, spawnPosition, Quaternion.identity, this.transform);//掛在這個chunk的parent上
        }
    }

    void SpawnApples()
    {
        //防止availableLanes 被取光抱錯 要加availableLanes.Count <= 0
        if (Random.value > appleSpawnChance || availableLanes.Count <= 0) return;

        int selectedLane = GetRandomAvailableLaneIndex();

        Vector3 spawnPosition = new Vector3(lanes[selectedLane], transform.position.y, transform.position.z);

        // Chunk 本身知道 levelGenerator 是誰，就負責幫忙轉交給 Apple
        Apple newApple = Instantiate(ApplePrefab, spawnPosition, Quaternion.identity, this.transform).GetComponent<Apple>();
        newApple.Init(levelGenerator);// 傳進 Apple
    }

    void SpawnCoins()
    {
        if (Random.value > coinSpawnChance || availableLanes.Count <= 0) return;

        int selectedLane = GetRandomAvailableLaneIndex();
        int maxCoinsToSpawn = 6;//最多生成幾個
        int coinsToSpawn = Random.Range(1, maxCoinsToSpawn);

        float topOfChunkZPos = transform.position.z + (coinSeparationLength * 2f);//這行不太懂為什麼要*2

        for (int i = 0; i < coinsToSpawn; i++)
        {
            float spawnPositionZ = topOfChunkZPos - (i * coinSeparationLength);//不懂這行
            Vector3 spawnPosition = new Vector3(lanes[selectedLane], transform.position.y, spawnPositionZ);
            //掛在這個chunk的parent上
            Coin newCoin = Instantiate(coinPrefab, spawnPosition, Quaternion.identity, this.transform).GetComponent<Coin>();
            newCoin.Init(scoreManager);
        }

    }

    private int GetRandomAvailableLaneIndex()
    {
        int randomLaneIndex = Random.Range(0, availableLanes.Count);//隨機找一個車道索引
        int selectedLane = availableLanes[randomLaneIndex];//複製 上面隨機找的那個車道 到selectedLane裡面
        availableLanes.RemoveAt(randomLaneIndex);//把 隨機找一個車道索引 從清單裡移除
        return selectedLane;// ← 這行把整數回傳出去
    }

}
