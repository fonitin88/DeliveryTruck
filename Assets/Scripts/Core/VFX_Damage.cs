using System.Collections;
using UnityEngine;

public class VFX_Damage : MonoBehaviour
{
    [SerializeField] int damage = 1;
    [SerializeField] float damageDuring = 0.5f;
    IDamageable target;
    Coroutine damageCo;

    public void SetDamage(int value)
    {
        damage = value;
    }

    void OnTriggerEnter(Collider other)
    {
        //有沒有IDamageable 的 component
        target = other.GetComponent<IDamageable>();
        if (target != null)
        {
            target.TakeDamage(damage);
            damageCo = StartCoroutine(damageLoop());
        }
        Debug.Log("Enter: " + other.name);

    }
    void OnTriggerExit(Collider other)
    {
        if (damageCo != null) StopCoroutine(damageCo);
        damageCo = null;
        target = null;
    }
    IEnumerator damageLoop()
    {
        while (true)
        {
            yield return new WaitForSeconds(damageDuring);
            if (target == null) yield break; //「我不要再當 Coroutine 了」
            target.TakeDamage(damage);
        }

    }
}
