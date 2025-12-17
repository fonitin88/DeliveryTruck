using UnityEngine;

public class SpeedUp : Van_PickUp
{
    [SerializeField] float speedamount = 0.5f;
    [SerializeField] float TimeLit = 5f;
    protected override void OnPickup(GameObject player)
    {
        Van_PlayerMovement playermove = player.GetComponent<Van_PlayerMovement>();
        playermove.SpeedUP(speedamount, TimeLit);
    }
}
