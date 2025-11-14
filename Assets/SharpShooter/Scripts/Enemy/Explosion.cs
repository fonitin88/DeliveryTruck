using UnityEngine;

public class Explosion : MonoBehaviour
{
    [SerializeField] float radius = 1.5f;
    [SerializeField] int damage = 3;

    void Start()
    {
        Explode();
    }

    void OnDrawGizmos()//這只是給debug使用 不會再play gameview顯示
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, radius);
    }

    void Explode()
    {
        // 球體半徑內的collider = Collider 的陣列
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, radius);
        foreach (Collider hitCollider in hitColliders)
        {
            PlayerHealth playerHealth = hitCollider.GetComponent<PlayerHealth>();

            if (!playerHealth) continue;//如果沒有playerHealth就不執行那個
            playerHealth.TakeDamage(damage);
            break;
            // if (playerHealth){ playerHealth.TakeDamage(damage);}可以這樣寫
            //playerHealth?.TakeDamage(damage); 也可以這樣寫 
        }
    }
}
