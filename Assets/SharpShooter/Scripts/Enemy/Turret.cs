using System.Collections;
using UnityEngine;

public class Turret : MonoBehaviour
{
    [SerializeField] Transform turrentHead;
    [SerializeField] Transform playerTargetPoint;
    [SerializeField] Transform projectileSpawnPoint;
    [SerializeField] GameObject projectilesPrefab;
    [SerializeField] float fireRate = 2f;
    [SerializeField] int damage = 2;

    PlayerHealth player;

    void Start()
    {
        player = FindFirstObjectByType<PlayerHealth>();
        StartCoroutine(FireRoutine());
    }

    void Update()
    {
        turrentHead.LookAt(playerTargetPoint);//讓他follow玩家 轉
    }

    IEnumerator FireRoutine()//發射子彈
    {
        while (player)
        {
            yield return new WaitForSeconds(fireRate);
            // 1. 產生子彈（方向暫時是預設）
            Projectiles newProjectiles = Instantiate(projectilesPrefab, projectileSpawnPoint.position, Quaternion.identity).GetComponent<Projectiles>();
            // 2. 轉頭面向玩家
            newProjectiles.transform.LookAt(playerTargetPoint);
            // 3. 告訴子彈它的傷害值
            newProjectiles.Init(damage);

        }
    }
}
