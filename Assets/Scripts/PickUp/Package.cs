using UnityEngine;

public class Package : Van_PickUp
{
    [SerializeField] int bonusValue = 1;

    BonusManager bonusManager;

    void Start()
    {
        bonusManager = FindFirstObjectByType<BonusManager>();
    }

    public void Init(BonusManager bonusManager)
    {
        this.bonusManager = bonusManager;
    }
    protected override void OnPickup(GameObject player)
    {
        bonusManager.IncreaseScore(bonusValue);
        Debug.Log("Bonus");
    }

}
