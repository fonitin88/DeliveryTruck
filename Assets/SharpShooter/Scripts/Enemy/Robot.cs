using StarterAssets;
using UnityEngine;
using UnityEngine.AI;

public class Robot : MonoBehaviour
{

    FirstPersonController player;
    NavMeshAgent agent;

    const string PLAYER_STRING = "Player";

    void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    void Start()
    {
        player = FindFirstObjectByType<FirstPersonController>();
    }

    void Update()
    {
        if (!player) return;

        agent.SetDestination(player.transform.position);
    }

    void OnTriggerEnter(Collider other)//判斷是不是player
    {
        if (other.CompareTag(PLAYER_STRING))//當player進去 就會自動爆炸
        {
            EnemyHealth enemyHealth = GetComponent<EnemyHealth>();//只用一次
            enemyHealth.SelfDestruct();
        }
    }
}
