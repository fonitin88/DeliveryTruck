using UnityEngine;

public class AmmoPickup : BasePickup
{
    [SerializeField] int ammoAmount = 100;
    protected override void OnPickup(ActiveWeapon activeWeapon)
    {
        activeWeapon.AdjustAmmo(ammoAmount);//重新補充子彈
    }
}
