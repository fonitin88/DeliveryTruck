using System.Collections;
using UnityEngine;

public class VFX_Damage : MonoBehaviour
{
    [SerializeField] int damage = 1;
    float T;
    float plusDamage;

    public void SetDamage(int value)
    {
        damage = value;
    }
    //改成只要在這個collision 內 都會一直扣，離開才不會扣，每秒一直扣
    //已經在trigger內
    //每秒扣
    void OnTriggerEnter(Collider other)
    {
        //有沒有IDamageable 的 component
        IDamageable target = other.GetComponent<IDamageable>();
        if (target != null)
        {

            target.TakeDamage(damage);


        }
    }
    IEnumerator damageDuring()
    {

        yield return new WaitForSeconds(T);
        plusDamage += damage;

    }
}
