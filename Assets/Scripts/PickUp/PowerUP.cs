using UnityEngine;

public class PowerUP : Van_PickUp
{
    [SerializeField] int amount = 2;
    [SerializeField] float TimeLit = 5f;
    protected override void OnPickup(GameObject player)
    {
        PlayerAttack playerAttack = player.GetComponent<PlayerAttack>();
        playerAttack.powerUp(amount, TimeLit);
    }
}
