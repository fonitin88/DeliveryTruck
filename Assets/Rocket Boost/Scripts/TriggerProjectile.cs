using UnityEngine;

public class TriggerProjectile : MonoBehaviour
{
    [SerializeField] GameObject projectile1;
    [SerializeField] GameObject projectile2;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            projectile1.SetActive(true);
            projectile2.SetActive(true);
            Destroy(gameObject);

        }

        //if player enter the trigger, the projectile will start active and active the ObjectHit cs

    }
}
