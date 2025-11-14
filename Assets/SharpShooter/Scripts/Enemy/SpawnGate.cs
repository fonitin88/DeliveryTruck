using System.Collections;
using UnityEngine;

public class SpawnGate : MonoBehaviour
{
    [SerializeField] GameObject enemyPrefab;
    [SerializeField] float spawnTime = 4f;
    [SerializeField] Transform spawnPoint;

    PlayerHealth player;

    void Start()
    {
        player = FindFirstObjectByType<PlayerHealth>();
        StartCoroutine(SpawnRoutine());
    }


    IEnumerator SpawnRoutine()
    {
        while (player)//while 是一直重複檢查條件
        {
            Instantiate(enemyPrefab, spawnPoint.position, transform.rotation);
            yield return new WaitForSeconds(spawnTime);
        }
    }
}
