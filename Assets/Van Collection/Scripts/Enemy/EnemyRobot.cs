
using UnityEngine;
using UnityEngine.AI;

public class EnemyRobot : MonoBehaviour
{
    Van_PlayerMovement player;
    NavMeshAgent agent;

    const string PLAYER_STRING = "Player";

    void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    void Start()
    {
        player = FindFirstObjectByType<Van_PlayerMovement>();
    }

    void Update()
    {
        if (!player) return;

        agent.SetDestination(player.transform.position);
    }

    void OnTriggerEnter(Collider other)//判斷是不是player
    {
        if (other.CompareTag(PLAYER_STRING))//還沒寫
        {
        }
    }
}
