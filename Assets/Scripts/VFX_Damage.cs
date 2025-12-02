using UnityEngine;

public class VFX_Damage : MonoBehaviour
{
    [SerializeField] int damage = 1;

    void OnTriggerEnter(Collider other)
    {
        Debug.Log("VFX hit: " + other.name);
        IDamageable target = other.GetComponent<IDamageable>();
        if (target != null)
        {
            target.TakeDamage(damage);

        }
    }
}
