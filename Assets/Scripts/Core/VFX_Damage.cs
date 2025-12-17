using UnityEngine;

public class VFX_Damage : MonoBehaviour
{
    [SerializeField] int damage = 1;

    public void SetDamage(int value)
    {
        damage = value;
    }

    void OnTriggerEnter(Collider other)
    {
        //有沒有實作 IDamageable 的 component
        IDamageable target = other.GetComponent<IDamageable>();
        if (target != null)
        {
            target.TakeDamage(damage);

        }
    }
}
