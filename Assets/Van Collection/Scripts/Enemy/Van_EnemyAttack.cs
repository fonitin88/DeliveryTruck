using System.Collections;
using UnityEngine;

public class Van_EnemyAttack : MonoBehaviour
{
    [SerializeField] GameObject VFXAttack;
    [SerializeField] float spawnTime = 4f;
    [SerializeField] Transform spawnPoint;

    const string PLAYER_STRING = "EnemyTrigger";

    Van_PlayerMovement player;
    Coroutine currentRoutine;

    void Start()
    {
        player = FindFirstObjectByType<Van_PlayerMovement>();

    }


    IEnumerator SpawnVFX()
    {
        while (player)
        {

            GameObject fx = Instantiate(VFXAttack, spawnPoint.position, transform.rotation);
            fx.transform.SetParent(spawnPoint);
            yield return new WaitForSeconds(spawnTime);
            Destroy(fx);
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(PLAYER_STRING) && currentRoutine == null)
        {
            currentRoutine = StartCoroutine(SpawnVFX());
        }
    }
    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(PLAYER_STRING) && currentRoutine != null)
        {
            StopCoroutine(currentRoutine);
            currentRoutine = null;
            // 立即清除所有特效物件
            foreach (Transform child in spawnPoint)
            {
                Destroy(child.gameObject);
            }
        }

    }
}

