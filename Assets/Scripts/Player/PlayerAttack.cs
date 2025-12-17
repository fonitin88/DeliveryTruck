using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;


public class PlayerAttack : MonoBehaviour
{
    [SerializeField] GameObject FX_Lightray;
    [SerializeField] GameObject Playerhitbox;
    [SerializeField] Transform FXShootPos;
    [SerializeField] float cooldown = 0.5f;
    [SerializeField] int baseDamge = 1;
    bool canAttack = true;

    Coroutine powerco;
    int bonusDamage = 0;

    public void OnShoot(InputValue input)
    {
        if (input.isPressed)
        {
            DoAttack();
        }
    }
    public void OnShootButton()
    {
        DoAttack();
    }
    void DoAttack()
    {
        if (!canAttack) return;
        StartCoroutine(AttackRoutine());

    }

    IEnumerator AttackRoutine()
    {
        canAttack = false;
        var hitbox = Instantiate(Playerhitbox, FXShootPos.position, transform.rotation, FXShootPos);
        var fx = Instantiate(FX_Lightray, FXShootPos.position, transform.rotation, FXShootPos);


        var dmg = hitbox.GetComponent<VFX_Damage>();
        if (dmg != null)
        {
            int finalDamage = baseDamge + bonusDamage;
            dmg.SetDamage(finalDamage);

            Debug.Log($"[Attack] Damage = {finalDamage}");
        }


        yield return new WaitForSeconds(cooldown);
        Destroy(hitbox);
        Destroy(fx);

        canAttack = true;
    }

    //處理連結pick的物件
    public void powerUp(int amount, float TimeLit)
    {
        //if (TimeLit <= 0f) return;
        bonusDamage = amount;
        if (powerco != null) StopCoroutine(powerco);
        powerco = StartCoroutine(PowerRoutine(TimeLit));
    }

    //只處裡時間
    IEnumerator PowerRoutine(float TimeLit)
    {
        yield return new WaitForSeconds(TimeLit);
        bonusDamage = 0;
        powerco = null;

    }


}
