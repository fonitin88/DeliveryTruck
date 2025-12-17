using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;


public class PlayerAttack : MonoBehaviour
{
    [SerializeField] GameObject FX_Lightray;
    [SerializeField] GameObject Playerhitbox;
    [SerializeField] Transform FXShootPos;
    [SerializeField] float cooldown = 0.5f;
    bool canAttack = true;
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
        yield return new WaitForSeconds(cooldown);
        Destroy(hitbox);
        Destroy(fx);

        canAttack = true;
    }


}
