
using UnityEngine;

public class Gas : Van_PickUp
{
    [SerializeField] int HealthValue = 10;


    protected override void OnPickup(GameObject player)
    {
        Van_AllHealth playerHealth = player.GetComponent<Van_AllHealth>();//只要呼叫通用 Health 腳本
        playerHealth.IncreaseHealth(HealthValue); //使用腳本的IncreaseHealth

    }

}
